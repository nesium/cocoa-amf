//
//  Client.h
//  CocoaAMF
//
//  Created by Marc Bauer on 28.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AsyncSocket.h"
#import "AMFByteArray.h"


@interface Client : NSObject
{
	AsyncSocket *m_socket;
	id m_delegate;
	BOOL m_binaryMode;
}
@property (nonatomic, assign) id delegate;
- (id)initWithSocket:(AsyncSocket *)socket;

- (void)sendObject:(NSObject *)obj;
- (void)sendData:(NSData *)data;
- (void)sendRawData:(NSData *)data;
- (void)continueReading;
- (void)disconnect;
@end


@protocol ClientDelegate

@optional
- (void)client:(Client *)client didReceiveData:(NSObject *)data;
- (void)clientDidDisconnect:(Client *)client;

@end