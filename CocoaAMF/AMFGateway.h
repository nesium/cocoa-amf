//
//  AMFGateway.h
//  RSFGameServer
//
//  Created by Marc Bauer on 23.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "AMFActionMessage.h"

#if TARGET_OS_IPHONE
#import <CFNetwork/CFNetwork.h>
#endif


@interface AMFGateway : NSObject
{
	AsyncSocket *m_socket;
	NSMutableArray *m_services;
	NSMutableArray *m_connections;
}

- (BOOL)startOnPort:(uint16_t)port error:(NSError **)error;
- (void)stop;
- (void)registerService:(NSObject *)service;

@end


@interface AMFConnection : NSObject
{
	AsyncSocket *socket;
	CFHTTPMessageRef request;
}

@property (nonatomic, retain) AsyncSocket *socket;
@property (nonatomic, assign) CFHTTPMessageRef request;

@end