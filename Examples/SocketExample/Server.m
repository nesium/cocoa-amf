//
//  Server.m
//  CocoaAMF
//
//  Created by Marc Bauer on 28.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "Server.h"


@implementation Server

- (id)init
{
	if (self = [super init])
	{
		m_clients = [[NSMutableSet alloc] init];
		m_socket = [[AsyncSocket alloc] initWithDelegate:self];
		[self start];
	}
	return self;
}

- (void)dealloc
{
	[m_clients release];
	[m_socket release];
	[super dealloc];
}


- (void)start
{
	NSError *error;
	if (![m_socket acceptOnPort:kPort error:&error])
	{
		NSLog(@"Error starting server: %@", error);
		return;
	}
	NSLog(@"Server started on port %d", [m_socket localPort]);
}



#pragma mark -
#pragma mark AsyncSocket Delegate methods

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	Client *client = [[Client alloc] initWithSocket:newSocket];
	client.delegate = self;
	[m_clients addObject:client];
	[client release];
}



#pragma mark -
#pragma mark Client delegate methods

- (void)client:(Client *)client didReceiveData:(NSObject *)data
{
	if ([data isKindOfClass:[NSData class]])
	{
		NSImage *image = [[NSImage alloc] initWithData:(NSData *)data];
		[m_imageView setImage:image];
		[image release];
		SimpleMessage *message = [[SimpleMessage alloc] init];
		message.message = @"Thank you flash";
		[client sendObject:message];
		[message release];
	}
	else if ([data isKindOfClass:[SimpleMessage class]])
	{
		NSLog(@"Received message: %@", [(SimpleMessage *)data message]);
	}
}

- (void)clientDidDisconnect:(Client *)client
{
	[m_clients removeObject:client];
}

@end