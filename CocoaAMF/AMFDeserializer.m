//
//  AMFDeserializer.m
//  CocoaAMF
//
//  Created by Marc Bauer on 11.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "AMFDeserializer.h"


@implementation AMFDeserializer

- (id)initWithStream:(AMFInputStream *)stream
{
	if (self = [super init])
	{
		m_stream = [stream retain];
	}
	return self;
}

- (void)dealloc
{
	[m_stream release];
	[super dealloc];
}

- (id)deserialize
{
	return nil;
}

- (NSString *)readString
{
	return nil;
}

@end