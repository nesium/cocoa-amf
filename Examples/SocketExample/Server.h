//
//  Server.h
//  CocoaAMF
//
//  Created by Marc Bauer on 28.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AsyncSocket.h"
#import "Client.h"
#import "SimpleMessage.h"


#define kPort 1235

@interface Server : NSObject
{
	IBOutlet NSImageView *m_imageView;

	NSMutableSet *m_clients;
	AsyncSocket *m_socket;
}
- (void)start;
@end