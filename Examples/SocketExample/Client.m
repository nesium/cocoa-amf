//
//  Client.m
//  CocoaAMF
//
//  Created by Marc Bauer on 28.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "Client.h"

#define kReadDataLengthTag 1
#define kReadDataTag 2

@implementation Client

@synthesize delegate=m_delegate;

- (id)initWithSocket:(AsyncSocket *)socket
{
	if (self = [super init])
	{
		m_binaryMode = NO;
		m_socket = [socket retain];
		[socket setDelegate:self];
		[self continueReading];
	}
	return self;
}

- (void)dealloc
{
	[m_socket release];
	[super dealloc];
}


- (void)sendObject:(NSObject *)obj
{
	AMFByteArray *ba = [[AMFByteArray alloc] initWithData:[NSMutableData data] 
		encoding:kAMF3Version];
	[ba writeObject:obj];
	[self sendData:ba.data];
	[ba release];
}

- (void)sendData:(NSData *)data
{
	if (![m_socket isConnected])
	{
		NSLog(@"Socket not connected");
		return;
	}
	uint32_t objDataLength = CFSwapInt32HostToBig([data length]);
	NSMutableData *lengthBits = [NSMutableData data];
	[lengthBits appendBytes:&objDataLength length:sizeof(uint32_t)];
	[m_socket writeData:lengthBits withTimeout:-1 tag:0];
	[m_socket writeData:data withTimeout:-1 tag:0];
}

- (void)sendRawData:(NSData *)data
{
	[m_socket writeData:data withTimeout:-1 tag:0];
}

- (void)continueReading
{
	if (!m_binaryMode)
	{
		[m_socket readDataToData:[AsyncSocket ZeroData] withTimeout:-1 tag:0];
		return;
	}
	[m_socket readDataToLength:4 withTimeout:-1 tag:kReadDataLengthTag];
}

- (void)disconnect
{
	if (![m_socket isConnected])
	{
		return;
	}
	[m_socket disconnectAfterWriting];
}



#pragma mark -
#pragma mark AsyncSocket Delegate methods

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
		AMFByteArray *ba = [[AMFByteArray alloc] initWithData:data encoding:kAMF3Version];
		NSObject *obj = [ba readObject];
		if ([m_delegate respondsToSelector:@selector(client:didReceiveData:)])
		{
			[m_delegate client:self didReceiveData:obj];
		}
		[ba release];
		[self continueReading];
	}
	else if (m_binaryMode == NO)
	{
		NSString *message = [NSString stringWithUTF8String:[data bytes]];
		if ([message isEqualToString:@"<policy-file-request/>"])
		{
			NSMutableString *policyMessage = [NSMutableString string];
			[policyMessage appendString:@"<cross-domain-policy>\n"];
			NSArray *allowedDomains = [NSArray arrayWithObject:@"*"];
			for (NSString *domain in allowedDomains)
			{
				[policyMessage appendFormat:@"<allow-access-from domain=\"%@\" to-ports=\"%d\"/>\n", 
					domain, [m_socket localPort]];
			}
			[policyMessage appendString:@"</cross-domain-policy>\0"];
			NSLog(@"send: %@", policyMessage);
			[self sendRawData:[policyMessage dataUsingEncoding:NSUTF8StringEncoding]];
			[self continueReading];
		}
		else if ([message isEqualToString:@"BIN-INIT"])
		{
			NSLog(@"switching to binary mode");
			m_binaryMode = YES;
			[self continueReading];
		}
		else
		{
			NSLog(@"received unexpected data");
			[self disconnect];
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
	if ([m_delegate respondsToSelector:@selector(clientDidDisconnect:)])
	{
		[m_delegate clientDidDisconnect:self];
	}
}

@end