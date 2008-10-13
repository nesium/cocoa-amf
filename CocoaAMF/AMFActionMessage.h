//
//  AMFActionMessage.h
//  SimpleHTTPServer
//
//  Created by Marc Bauer on 12.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMFMessageHeader.h"
#import "AMFMessageBody.h"


@interface AMFActionMessage : NSObject 
{
	uint16_t m_version;
	NSArray *m_headers;
	NSArray *m_bodies;
}

@property (nonatomic, assign) uint16_t version;
@property (nonatomic, retain) NSArray *headers;
@property (nonatomic, retain) NSArray *bodies;

@end