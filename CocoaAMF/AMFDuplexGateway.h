//
//  AMFDuplexSocket.h
//  CocoaAMF
//
//  Created by Marc Bauer on 20.02.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMF.h"
#import "AMFActionMessage.h"
#import "AsyncSocket.h"


@interface AMFDuplexGateway : NSObject 
{
	AsyncSocket *m_socket;
	AsyncSocket *m_remote;
	NSMutableDictionary *m_services;
	NSMutableDictionary *m_remoteServices;
}

- (BOOL)startOnPort:(uint16_t)port error:(NSError **)error;
- (void)stop;

- (void)registerService:(id)service withName:(NSString *)name;
- (void)unregisterServiceWithName:(NSString *)name;

- (void)invokeRemoteService:(NSString *)serviceName methodName:(NSString *)methodName 
	arguments:(NSArray *)arguments;

@end