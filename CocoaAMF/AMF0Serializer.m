//
//  AMF0Serializer.m
//  SimpleHTTPServer
//
//  Created by Marc Bauer on 12.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "AMF0Serializer.h"

@interface AMF0Serializer (Private)
- (void)writeString:(NSString *)value;
@end


@implementation AMF0Serializer

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithStream:(AMFOutputStream *)stream avmPlus:(BOOL)avmPlus
{
	if (self = [super init])
	{
		m_stream = [stream retain];
		m_avmPlus = avmPlus;
	}
	return self;
}

- (void)dealloc
{
	[m_stream release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)serialize:(NSObject *)value
{
	if (value == nil)
	{
		[m_stream writeUInt8:kAMF0NullType];
	}
	else if ([value isKindOfClass:[NSString class]])
	{
		[self writeString:(NSString *)value];
	}
}



#pragma mark -
#pragma mark Private methods

- (void)writeString:(NSString *)value
{
	NSData *stringData = [value dataUsingEncoding:NSUTF8StringEncoding];
	
	if ([stringData length] > 0xFFFF)
	{
		[m_stream writeUInt8:kAMF0LongStringType];
		[m_stream writeUInt32:[stringData length]];
	}
	else
	{
		[m_stream writeUInt8:kAMF0StringType];
		[m_stream writeUInt16:[stringData length]];
	}
	
	[m_stream writeData:stringData];
}

@end