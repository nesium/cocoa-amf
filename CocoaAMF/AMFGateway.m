// Based on SimpleHTTPServer by Deusty Designs
// 
// Software License Agreement (BSD License)
// 
// Copyright (c) 2006, Deusty Designs, LLC
// All rights reserved.
// 
// Redistribution and use of this software in source and binary forms,
// with or without modification, are permitted provided that the following conditions are met:
// 
// * Redistributions of source code must retain the above
//   copyright notice, this list of conditions and the
//   following disclaimer.
// 
// * Neither the name of Desuty Designs nor the names of its
//   contributors may be used to endorse or promote products
//   derived from this software without specific prior
//   written permission of Deusty Designs, LLC.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR 
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
// AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF 
// USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
// ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

//
//  AMFGateway.m
//  RSFGameServer
//
//  Created by Marc Bauer on 23.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "AMFGateway.h"

#if TARGET_OS_IPHONE
#import "NSObject-iPhoneExtensions.h"
#endif

// Define the various timeouts (in seconds) for various parts of the HTTP process
#define READ_TIMEOUT        -1
#define WRITE_HEAD_TIMEOUT  30
#define WRITE_BODY_TIMEOUT  -1
#define WRITE_ERROR_TIMEOUT 30

// Define the various tags we'll use to differentiate what it is we're currently doing
#define HTTP_REQUEST           15
#define HTTP_PARTIAL_RESPONSE  29
#define HTTP_RESPONSE          30
#define HTTP_BODY			   31


@interface AMFGateway (Private)
- (AMFConnection *)_connectionForSocket:(AsyncSocket *)sock;
- (AMFActionMessage *)_processAMFRequestWithHeader:(AMFMessageHeader *)requestHeader 
	body:(AMFMessageBody *)requestBody;
- (AMFActionMessage *)_processFlexRemoteObjectRequest:(AMFMessageBody *)requestBody;
- (id)_executeService:(NSString *)serviceName method:(NSString *)methodName 
	arguments:(NSArray *)arguments error:(NSError **)error;
@end

#define kAMFGatewayErrorDomain @"AMFGatewayErrorDomain"


@implementation AMFGateway

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init
{
	if (self = [super init])
	{
		m_socket = [[AsyncSocket alloc] initWithDelegate:self];
		m_services = [[NSMutableArray alloc] init];
		m_connections = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[self stop];
	[m_socket release];
	[m_services release];
	[m_connections release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (BOOL)startOnPort:(uint16_t)port error:(NSError **)error
{
	BOOL success = [m_socket acceptOnPort:port error:error];
	if (success)
	{
		NSLog(@"Server started on port %d", [m_socket localPort]);
	}
	return success;
}

- (void)stop
{
	[m_socket disconnect];
}

- (void)registerService:(NSObject *)service
{
	[m_services addObject:service];
}



#pragma mark -
#pragma mark Private methods

- (AMFConnection *)_connectionForSocket:(AsyncSocket *)sock
{
	for (AMFConnection *connection in m_connections)
	{
		if (connection.socket == sock)
		{
			return connection;
		}
	}
	return nil;
}

- (NSObject *)_serviceForName:(NSString *)name
{
	for (NSObject *service in m_services)
	{
		if ([[service className] isEqualToString:name])
		{
			return service;
		}
	}
	return nil;
}

- (AMFActionMessage *)_processAMFRequestWithHeader:(AMFMessageHeader *)requestHeader 
	body:(AMFMessageBody *)requestBody
{
	NSArray *targetComponents = [requestBody.targetURI componentsSeparatedByString:@"."];
	AMFActionMessage *response = [[AMFActionMessage alloc] init];
	NSString *targetURI = [NSString stringWithFormat:@"%@/onResult", requestBody.responseURI];
	NSObject *data = nil;
	NSError *error = nil;
	
	if ([targetComponents count] < 2)
	{
		error = [NSError errorWithDomain:kAMFGatewayErrorDomain code:kAMFErrorServiceNotFound 
			userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
				@"Either the service or the method to execute was not specified.", 
				NSLocalizedDescriptionKey, nil]];
	}
	else if (![requestBody.data isKindOfClass:[NSArray class]])
	{
		error = [NSError errorWithDomain:kAMFGatewayErrorDomain code:kAMFErrorInvalidArguments 
			userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
				@"The root object should be an array", NSLocalizedDescriptionKey, nil]];
	}
	else
	{
		data = [self _executeService:[targetComponents objectAtIndex:0] 
			method:[targetComponents objectAtIndex:1] arguments:(NSArray *)requestBody.data 
			error:&error];
	}
	
	if (error != nil)
	{
		targetURI = [NSString stringWithFormat:@"%@/onStatus", requestBody.responseURI];
		data = [error description];
	}
	[response addBodyWithTargetURI:targetURI responseURI:nil data:data];
	return [response autorelease];
}

- (AMFActionMessage *)_processFlexRemoteObjectRequest:(AMFMessageBody *)requestBody
{
	NSObject *request = [(NSArray *)requestBody.data objectAtIndex:0];
	NSString *targetURI = [NSString stringWithFormat:@"%@/onResult", requestBody.responseURI];
	NSObject *body = nil;
	NSObject *data = nil;
	NSError *error = nil;
	
	if ([request isMemberOfClass:[FlexCommandMessage class]])
	{
		if ([(FlexCommandMessage *)request operation] != kFlexCommandMessageClientPingOperation)
		{
			error = [NSError errorWithDomain:kAMFGatewayErrorDomain code:kAMFErrorInvalidRequest 
				userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
					[NSString stringWithFormat:@"Operation type %d not supported.", 
						[(FlexCommandMessage *)request operation]], 
					NSLocalizedDescriptionKey, nil]];
		}
	}
	else if ([request isMemberOfClass:[FlexRemotingMessage class]])
	{
		FlexRemotingMessage *remotingMessage = (FlexRemotingMessage *)request;
		if (![remotingMessage.body isKindOfClass:[NSArray class]])
		{
			error = [NSError errorWithDomain:kAMFGatewayErrorDomain code:kAMFErrorInvalidArguments 
				userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
					@"The root object should be an array.", NSLocalizedDescriptionKey, nil]];
		}
		else
		{
			body = [self _executeService:remotingMessage.destination 
				method:remotingMessage.operation arguments:(NSArray *)remotingMessage.body 
				error:&error];
		}
	}
	else if ([request isMemberOfClass:[FlexAsyncMessage class]])
	{
	}
	else
	{
		error = [NSError errorWithDomain:kAMFGatewayErrorDomain code:kAMFErrorInvalidRequest 
			userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
				[NSString stringWithFormat:@"Operation type %d not supported.", 
					[(FlexCommandMessage *)request operation]], 
				NSLocalizedDescriptionKey, nil]];
	}

	NSString *correlationId = [request isKindOfClass:[FlexAbstractMessage class]] ? 
		[(FlexAbstractMessage *)request messageId] : nil;
	if (error != nil)
	{
		FlexErrorMessage *errorMessage = [FlexErrorMessage errorMessageWithError:error];
		errorMessage.correlationId = correlationId;
		data = errorMessage;
		targetURI = [NSString stringWithFormat:@"%@/onStatus", requestBody.responseURI];
	}
	else
	{
		FlexAcknowledgeMessage *ack = [[FlexAcknowledgeMessage alloc] init];
		ack.correlationId = correlationId;
		ack.body = body;
		data = [ack autorelease];
	}

	AMFActionMessage *response = [[AMFActionMessage alloc] init];
	[response addBodyWithTargetURI:targetURI responseURI:nil data:data];
	return [response autorelease];
}

- (id)_executeService:(NSString *)serviceName method:(NSString *)methodName 
	arguments:(NSArray *)arguments error:(NSError **)error
{
	NSObject *service = [self _serviceForName:serviceName];
	// service not found
	if (service == nil)
	{
		*error = [NSError errorWithDomain:kAMFGatewayErrorDomain code:kAMFErrorServiceNotFound 
			userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
				[NSString stringWithFormat:@"Service %@ not found", serviceName], 
				NSLocalizedDescriptionKey, nil]];
		return nil;
	}
	
	return [service invokeMethodWithName:methodName arguments:arguments error:error];
}

- (void)_sendHTTPError:(uint16_t)errorNo toConnection:(AMFConnection *)connection
{
	AsyncSocket *socket = connection.socket;
	CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, errorNo, NULL, 
		kCFHTTPVersion1_1);
	CFHTTPMessageSetHeaderFieldValue(response, CFSTR("Content-Length"), CFSTR("0"));
	NSData *responseData = [(NSData *)CFHTTPMessageCopySerializedMessage(response) autorelease];
	[socket writeData:responseData withTimeout:WRITE_ERROR_TIMEOUT tag:HTTP_RESPONSE];
	CFRelease(response);
}

- (void)_replyToHTTPRequestWithConnection:(AMFConnection *)connection
{
	AsyncSocket *socket = connection.socket;
	CFHTTPMessageRef request = connection.request;

	// Check the HTTP version
	// If it's anything but HTTP version 1.1, we don't support it
	NSString *version = [(NSString *)CFHTTPMessageCopyVersion(request) autorelease];
    if(!version || ![version isEqualToString:(NSString *)kCFHTTPVersion1_1])
	{
		NSLog(@"HTTP Server: Error 505 - Version Not Supported");
		[self _sendHTTPError:505 toConnection:connection];
        return;
    }
	
	// Check HTTP method
	// If no method was passed, issue a Bad Request response
    NSString *method = [(NSString *)CFHTTPMessageCopyRequestMethod(request) autorelease];
    if(!method)
	{
		NSLog(@"HTTP Server: Error 400 - Bad Request");
		[self _sendHTTPError:400 toConnection:connection];
        return;
    }
	
	// Extract requested URI
	// NSURL *uri = [(NSURL *)CFHTTPMessageCopyRequestURL(request) autorelease];
	
    if ([method isEqualToString:@"GET"] || [method isEqualToString:@"HEAD"])
	{
		NSLog(@"HTTP Server: Error 404 - Not Found");
		[self _sendHTTPError:404 toConnection:connection];
		return;
    }
	
	CFStringRef contentType = CFHTTPMessageCopyHeaderFieldValue(request, CFSTR("Content-Type"));
	if ([method isEqualToString:@"POST"] && CFStringFind(contentType, CFSTR("application/x-amf"), 
		kCFCompareCaseInsensitive).location != kCFNotFound)
	{
		CFDataRef messageBody = CFHTTPMessageCopyBody(request);
		
		if (messageBody == NULL)
		{
			NSLog(@"HTTP Server: Error 400 - Bad Request");
			[self _sendHTTPError:400 toConnection:connection];
			CFRelease(contentType);
			return;
		}
		
		AMFActionMessage *amfRequest = [[AMFActionMessage alloc] 
			initWithData:(NSData *)messageBody];
		
		AMFActionMessage *amfResponse = [[AMFActionMessage alloc] init];
		amfResponse.version = amfRequest.version;
		
		for (uint16_t i = 0; i < [amfRequest messagesCount]; i++)
		{
			AMFMessageBody *amfRequestBody = [amfRequest bodyAtIndex:i];
			if ([amfRequestBody.targetURI isEqualToString:@"null"])
			{
				[amfResponse mergeActionMessage:[self _processFlexRemoteObjectRequest:
					amfRequestBody]];
			}
			else
				[amfResponse mergeActionMessage:[self _processAMFRequestWithHeader:
					[amfRequest headerAtIndex:i] body:amfRequestBody]];
		}
		
		NSData *amfResponseData = [amfResponse data];
		CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, 200, NULL, 
			kCFHTTPVersion1_1);
		CFHTTPMessageSetHeaderFieldValue(response, CFSTR("Content-Type"), 
			CFSTR("application/x-amf"));
        CFHTTPMessageSetHeaderFieldValue(response, CFSTR("Content-Length"), 
			(CFStringRef)[NSString stringWithFormat:@"%i", [amfResponseData length]]);
		NSData *responseData = [(NSData *)CFHTTPMessageCopySerializedMessage(response) autorelease];
		[socket writeData:responseData withTimeout:WRITE_HEAD_TIMEOUT tag:HTTP_PARTIAL_RESPONSE];
		[socket writeData:amfResponseData withTimeout:WRITE_BODY_TIMEOUT tag:HTTP_RESPONSE];
		
		[amfResponse release];
		[amfRequest release];
		CFRelease(messageBody);
		CFRelease(response);
		CFRelease(contentType);		
		return;
	}
	
	CFRelease(contentType);
	NSLog(@"HTTP Server: Error 405 - Method Not Allowed: %@", method);
	[self _sendHTTPError:405 toConnection:connection];
}



#pragma mark -
#pragma mark AsyncSocket Delegate methods

-(void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	AMFConnection *connection = [[AMFConnection alloc] init];
	connection.socket = newSocket;
	[m_connections addObject:connection];
	[connection release];
	[newSocket readDataToData:[AsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:HTTP_REQUEST];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData*)data withTag:(long)tag
{
	AMFConnection *connection = [self _connectionForSocket:sock];
	CFHTTPMessageAppendBytes(connection.request, [data bytes], [data length]);
	if (!CFHTTPMessageIsHeaderComplete(connection.request))
	{
		[sock readDataToData:[AsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:HTTP_REQUEST];
	}
	else if (tag == HTTP_REQUEST)
	{
		CFDictionaryRef headerFields = CFHTTPMessageCopyAllHeaderFields(connection.request);
		[sock readDataToLength:CFStringGetIntValue(
			CFDictionaryGetValue(headerFields, CFSTR("Content-Length"))) 
			withTimeout:READ_TIMEOUT tag:HTTP_BODY];
		CFRelease(headerFields);
	}
	else
	{
		CFHTTPMessageSetBody(connection.request, (CFDataRef)data);
		[self _replyToHTTPRequestWithConnection:connection];
	}
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	if (tag == HTTP_RESPONSE)
	{
		[sock disconnectAfterWriting];
	}
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	[m_connections removeObject:[self _connectionForSocket:sock]];
}

@end



@implementation AMFConnection

@synthesize socket, request;

- (id)init
{
	if (self = [super init])
	{
		request = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, YES);
	}
	return self;
}

- (void)dealloc
{
	[socket release];
	CFRelease(request);
	[super dealloc];
}

@end