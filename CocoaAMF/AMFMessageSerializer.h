//
//  AMFMessageSerializer.h
//  SimpleHTTPServer
//
//  Created by Marc Bauer on 12.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMFOutputStream.h"
#import "AMF0Serializer.h"
#import "AMFActionMessage.h"
#import "AMFMessageHeader.h"
#import "AMFMessageBody.h"
#import "AMFKeyedArchiver.h"


@interface AMFMessageSerializer : NSObject 
{
	AMFOutputStream *m_stream;
}

- (NSData *)serialize:(AMFActionMessage *)message;

@end