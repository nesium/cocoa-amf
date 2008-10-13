//
//  AMFDeserializer.h
//  CocoaAMF
//
//  Created by Marc Bauer on 11.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMFInputStream.h"


@interface AMFDeserializer : NSObject 
{
	AMFInputStream *m_stream;
}

- (id)initWithStream:(AMFInputStream *)stream;
- (id)deserialize;

@end