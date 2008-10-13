//
//  AMFMessageSerializer.m
//  SimpleHTTPServer
//
//  Created by Marc Bauer on 12.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "AMFMessageSerializer.h"

@interface AMFMessageSerializer (Private)
- (void)writeHeader:(AMFMessageHeader *)header avmPlus:(BOOL)avmPlus;
- (void)writeBody:(AMFMessageBody *)body avmPlus:(BOOL)avmPlus;
- (void)writeString:(NSString *)value;
@end


@implementation AMFMessageSerializer

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init
{
	if (self = [super init])
	{
		m_stream = [[AMFOutputStream alloc] init];
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

- (NSData *)serialize:(AMFActionMessage *)message
{
	BOOL avmPlus = message.version == 3;

	[m_stream writeUInt16:message.version];
	
	[m_stream writeUInt16:[message.headers count]];
	for (AMFMessageHeader *header in message.headers)
	{
		[self writeHeader:header avmPlus:avmPlus];
	}
	
	[m_stream writeUInt16:[message.bodies count]];
	for (AMFMessageBody *body in message.bodies)
	{
		NSLog(@"Serialize body");
		[self writeBody:body avmPlus:avmPlus];
	}
	return [[m_stream.data copy] autorelease];
}



#pragma mark -
#pragma mark Private methods

- (void)writeHeader:(AMFMessageHeader *)header avmPlus:(BOOL)avmPlus
{
	[self writeString:header.name];
	
	AMFOutputStream *headerStream = [[AMFOutputStream alloc] init];
	AMF0Serializer *serializer = [[AMF0Serializer alloc] initWithStream:headerStream 
		avmPlus:avmPlus];
	[serializer serialize:header.data];
	
	[m_stream writeUInt32:[headerStream.data length]];
	[m_stream writeData:headerStream.data];
	
	[headerStream release];
	[serializer release];
}

- (void)writeBody:(AMFMessageBody *)body avmPlus:(BOOL)avmPlus
{
	if (body.targetURI != nil)
	{
		[self writeString:body.targetURI];
	}
	else
	{
		[self writeString:@"null"];
	}
	
	if (body.responseURI != nil)
	{
		[self writeString:body.responseURI];
	}
	else
	{
		[self writeString:@"null"];
	}
	
	NSData *bodyData = [AMFKeyedArchiver archivedDataWithRootObject:body.data];
	[m_stream writeUInt32:[bodyData length]];
	[m_stream writeData:bodyData];
}

- (void)writeString:(NSString *)value
{
	NSData *stringData = [value dataUsingEncoding:NSUTF8StringEncoding];
	[m_stream writeUInt16:[stringData length]];
	[m_stream writeData:stringData];
}

@end