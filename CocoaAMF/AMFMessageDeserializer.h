//
//  AMFMessageDeserializer.h
//  CocoaAMF
//
//  Created by Marc Bauer on 11.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMFInputStream.h"
#import "AMFActionMessage.h"
#import "AMF0Deserializer.h"
#import "AMFMessageHeader.h"
#import "AMFMessageBody.h"


@interface AMFMessageDeserializer : NSObject 
{
	AMFInputStream *m_stream;
	AMF0Deserializer *m_deserializer;
}

- (id)initWithAMFStream:(AMFInputStream *)stream;
- (AMFActionMessage *)deserialize;

@end