//
//  AMFDuplexSocket.m
//  CocoaAMF
//
//  Created by Marc Bauer on 20.02.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "AMFDuplexGateway.h"

#define kReadDataLengthTag 1
#define kReadDataTag 2

@interface AMFDuplexGateway (Private)
- (void)_continueReading;
- (void)_sendActionMessage:(AMFActionMessage *)am;
- (void)_processActionMessage:(AMFActionMessage *)am;
- (void)_processResponseWithServiceName:(NSString *)serviceName methodName:(NSString *)methodName 
	responseData:(id)responseData invocationIndex:(int)invocationIndex 
	resultType:(NSString *)resultType;
@end

@implementation AMFDuplexGateway

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init
{
	if (self = [super init])
	{
		m_socket = [[AsyncSocket alloc] init];
		[m_socket setDelegate:self];
		m_services = [[NSMutableDictionary alloc] init];
		m_remoteServices = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[m_socket disconnect];
	[m_socket release];
	[m_remote release];
	[m_services release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (BOOL)startOnPort:(uint16_t)port error:(NSError **)error
{
	if (![m_socket acceptOnPort:port error:error])
	{
		NSLog(@"Error starting server: %@", error);
		return NO;
	}
	NSLog(@"Server started on port %d", [m_socket localPort]);
	return YES;
}

- (void)stop
{
	[m_socket disconnect];
}

- (void)registerService:(id)service withName:(NSString *)name
{
	[m_services setObject:service forKey:name];
}

- (void)unregisterServiceWithName:(NSString *)name
{
	[m_services removeObjectForKey:name];
}

- (void)invokeRemoteService:(NSString *)serviceName methodName:(NSString *)methodName 
	arguments:(NSArray *)arguments
{
	NSLog(@"send message");
	AMFActionMessage *am = [[AMFActionMessage alloc] init];
	[am addBodyWithTargetURI:[NSString stringWithFormat:@"%@.%@", serviceName, methodName] 
		responseURI:@"/1" data:arguments];
	[self _sendActionMessage:am];
}



#pragma mark -
#pragma mark Private methods

- (void)_continueReading
{
	[m_remote readDataToLength:4 withTimeout:-1 tag:kReadDataLengthTag];
}

- (void)_sendActionMessage:(AMFActionMessage *)am
{
	NSData *data = [am data];
	uint32_t msgDataLength = CFSwapInt32HostToBig([data length]);
	NSMutableData *lengthBits = [NSMutableData data];
	[lengthBits appendBytes:&msgDataLength length:sizeof(uint32_t)];
	[m_remote writeData:lengthBits withTimeout:-1 tag:0];
	[m_remote writeData:data withTimeout:-1 tag:0];
}

- (void)_processActionMessage:(AMFActionMessage *)am
{
	for (AMFMessageBody *body in am.bodies)
	{
		NSArray *targetComponents = [body.targetURI componentsSeparatedByString:@"."];
		NSString *serviceName = [targetComponents objectAtIndex:0];
		NSString *methodName = [targetComponents objectAtIndex:1];
		
		// is a response
		if ([body.responseURI rangeOfString:@"/"].location == NSNotFound)
		{
			NSArray *methodComponents = [methodName componentsSeparatedByString:@"/"];
			methodName = [methodComponents objectAtIndex:0];
			int responseIndex = [[methodComponents objectAtIndex:1] intValue];
			NSString *resultType = [methodComponents objectAtIndex:2];
			[self _processResponseWithServiceName:serviceName methodName:methodName 
				responseData:body.data invocationIndex:responseIndex resultType:resultType];
			continue;
		}
		id service = [m_services objectForKey:serviceName];
		SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:", methodName]);
		
		if (![service respondsToSelector:selector])
		{
			NSLog(@"Ouch. Either a service or a method is not existing. (%@)", body.targetURI);
			continue;
		}
		
		NSMethodSignature *signature = [service methodSignatureForSelector:selector];
		id result = [service performSelector:selector withObject:body.data];
		
		if (![signature isOneway])
		{
			AMFActionMessage *ram = [[AMFActionMessage alloc] init];
			[ram addBodyWithTargetURI:[NSString stringWithFormat:@"%@%@/onResult", body.targetURI, 
					body.responseURI] responseURI:@"null" data:result];
			[self _sendActionMessage:ram];
			[ram release];
		}
	}
}

- (void)_processResponseWithServiceName:(NSString *)serviceName methodName:(NSString *)methodName 
	responseData:(id)responseData invocationIndex:(int)invocationIndex 
	resultType:(NSString *)resultType
{
	
}



#pragma mark -
#pragma mark AsyncSocket delegate methods
 
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	[newSocket setDelegate:self];
	m_remote = [newSocket retain];
	[self _continueReading];
	[self invokeRemoteService:@"TestService" methodName:@"sayHello" 
		arguments:[NSArray arrayWithObject:@"World"]];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	if (tag == kReadDataLengthTag)
	{
		uint8_t ch1, ch2, ch3, ch4;
		[data getBytes:&ch1 range:(NSRange){0, 1}];
		[data getBytes:&ch2 range:(NSRange){1, 1}];
		[data getBytes:&ch3 range:(NSRange){2, 1}];
		[data getBytes:&ch4 range:(NSRange){3, 1}];
		uint32_t length = (ch1 << 24) + (ch2 << 16) + (ch3 << 8) + ch4;
		[sock readDataToLength:length withTimeout:-1 tag:kReadDataTag];
	}
	else if (tag == kReadDataTag)
	{
		AMFActionMessage *am = nil;
		@try
		{
			AMFActionMessage *am = [[AMFActionMessage alloc] initWithData:data];
			[self _processActionMessage:am];
			NSLog(@"%@", am);
		}
		@catch (NSException *e) 
		{
			NSLog(@"%@", e);
		}
		@finally 
		{
			[am release];
			[self _continueReading];
		}
	}
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
}
 
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	NSLog(@"will disconnect with error %@", err);
}
 
- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	NSLog(@"did disconnect");
}

@end