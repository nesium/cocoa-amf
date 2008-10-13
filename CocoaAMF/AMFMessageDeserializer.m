//
//  AMFMessageDeserializer.m
//  CocoaAMF
//
//  Created by Marc Bauer on 11.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "AMFMessageDeserializer.h"

@interface AMFMessageDeserializer (Private)
- (AMFMessageHeader *)readHeader;
- (AMFMessageBody *)readBody;
@end


@implementation AMFMessageDeserializer

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithAMFStream:(AMFInputStream *)stream
{
	if (self = [super init])
	{
		m_stream = [stream retain];
		m_deserializer = [[AMF0Deserializer alloc] initWithStream:stream];
	}
	return self;
}

- (void)dealloc
{
	[m_stream release];
	[m_deserializer release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (AMFActionMessage *)deserialize
{
	AMFActionMessage *message = [[[AMFActionMessage alloc] init] autorelease];
	message.version = [m_stream readUInt16];

	uint16_t headerCount = [m_stream readUInt16];
	NSMutableArray *headers = [[NSMutableArray alloc] initWithCapacity:headerCount];
	while (headerCount--)
	{
		[headers addObject:[self readHeader]];
	}
	
	uint16_t bodyCount = [m_stream readUInt16];
	NSMutableArray *bodies = [[NSMutableArray alloc] initWithCapacity:bodyCount];
	while (bodyCount--)
	{
		[bodies addObject:[self readBody]];
	}
	
	message.headers = [headers copy];
	message.bodies = [bodies copy];
	[message.headers release];
	[message.bodies release];
	
	[headers release];
	[bodies release];
	
	return message;
}



#pragma mark -
#pragma mark Private methods

- (AMFMessageHeader *)readHeader
{
	AMFMessageHeader *header = [[[AMFMessageHeader alloc] init] autorelease];
	header.name = [m_stream readUTF8:[m_stream readUInt16]];
	header.mustUnderstand = [m_stream readBool];
	uint32_t length = [m_stream readUInt32];
	NSLog(@"header data length: %d", length);
	header.data = [m_deserializer deserialize];
	NSLog(@"header data: %@", header.data);
	return header;
}

- (AMFMessageBody *)readBody
{
	AMFMessageBody *body = [[[AMFMessageBody alloc] init] autorelease];
	body.targetURI = [m_stream readUTF8:[m_stream readUInt16]];
	body.responseURI = [m_stream readUTF8:[m_stream readUInt16]];
	uint32_t length = [m_stream readUInt32];
	NSLog(@"body data length: %d", length);
	body.data = [m_deserializer deserialize];
	NSLog(@"body data: %@", body.data);
	return body;
}

@end