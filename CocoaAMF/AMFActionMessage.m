//
//  AMFActionMessage.m
//  SimpleHTTPServer
//
//  Created by Marc Bauer on 12.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "AMFActionMessage.h"


@implementation AMFActionMessage

@synthesize version=m_version;
@synthesize headers=m_headers;
@synthesize bodies=m_bodies;


#pragma mark -
#pragma mark Initialization & Deallcation

- (id)init
{
	if (self = [super init])
	{
		m_headers = nil;
		m_bodies = nil;
	}
	return self;
}

- (id)initWithData:(NSData *)data
{
	if (self = [super init])
	{
		AMFByteArray *ba = [[AMFByteArray alloc] initWithData:data encoding:kAMF0Version];
		m_version = [ba _decodeUnsignedShort];
		uint16_t numHeaders = [ba _decodeUnsignedShort];
		NSMutableArray *headers = [NSMutableArray arrayWithCapacity:numHeaders];
		for (uint16_t i = 0; i < numHeaders; i++)
		{
			AMFMessageHeader *header = [[AMFMessageHeader alloc] init];
			header.name = [ba _decodeUTF];
			header.mustUnderstand = [ba readBoolean];
			// Header length
			[ba _decodeUnsignedInt];
			header.data = [ba _decodeObject];
			[headers addObject:header];
			[header release];
		}
		m_headers = [headers copy];
		
		uint16_t numBodies = [ba _decodeUnsignedShort];
		NSMutableArray *bodies = [NSMutableArray arrayWithCapacity:numBodies];
		for (uint16_t i = 0; i < numBodies; i++)
		{
			AMFMessageBody *body = [[AMFMessageBody alloc] init];
			body.targetURI = [ba _decodeUTF];
			body.responseURI = [ba _decodeUTF];
			// Body length
			[ba _decodeUnsignedInt];
			body.data = [ba _decodeObject];
			[bodies addObject:body];
		}
		m_bodies = [bodies copy];
	}
	return self;
}

- (void)dealloc
{
	[m_headers release];
	[m_bodies release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (NSData *)data
{
	AMFByteArray *ba = [[AMFByteArray alloc] initWithData:[NSMutableData data] 
		encoding:kAMF0Version];
	[ba writeUnsignedShort:m_version];
	[ba writeUnsignedShort:[m_headers count]];
	for (AMFMessageHeader *header in m_headers)
	{
		[ba writeUTF:header.name];
		[ba writeBoolean:header.mustUnderstand];
		AMFByteArray *headerBa = [[AMFByteArray alloc] initWithData:[NSMutableData data] 
			encoding:m_version];
		if (m_version == kAMF3Version)
		{
			[headerBa writeUnsignedByte:kAMF0AVMPlusObjectType];
		}
		[headerBa writeObject:header.data];
		[ba writeUnsignedInt:[headerBa.data length]];
		[ba writeBytes:headerBa.data];
		[headerBa release];
	}
	[ba writeUnsignedShort:[m_bodies count]];
	for (AMFMessageBody *body in m_bodies)
	{
		body.targetURI != nil ? [ba writeUTF:body.targetURI] : [ba writeUTF:@"null"];
		body.responseURI != nil ? [ba writeUTF:body.responseURI] : [ba writeUTF:@"null"];
		AMFByteArray *bodyBa = [[AMFByteArray alloc] initWithData:[NSMutableData data] 
			encoding:m_version];
		if (m_version == kAMF3Version)
		{
			[bodyBa writeUnsignedByte:kAMF0AVMPlusObjectType];
		}
		[bodyBa writeObject:body.data];
		[ba writeUnsignedInt:[bodyBa.data length]];
		[ba writeBytes:bodyBa.data];
		[bodyBa release];
	}
	NSData *data = [[ba.data retain] autorelease];
	[ba release];
	
	return data;
}

@end



#pragma mark -



@implementation AMFMessageHeader

@synthesize name=m_name;
@synthesize mustUnderstand=m_mustUnderstand;
@synthesize data=m_data;


#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init
{
	if (self = [super init])
	{
		m_name = nil;
		m_mustUnderstand = NO;
		m_data = nil;
	}
	return self;
}

- (void)dealloc
{
	[m_name release];
	[m_data release];
	[super dealloc];
}

@end



#pragma mark -



@implementation AMFMessageBody

@synthesize targetURI=m_targetURI;
@synthesize responseURI=m_responseURI;
@synthesize data=m_data;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init
{
	if (self = [super init])
	{
		m_targetURI = nil;
		m_responseURI = nil;
		m_data = nil;
	}
	return self;
}

- (void)dealloc
{
	[m_targetURI release];
	[m_responseURI release];
	[m_data release];
	[super dealloc];
}

@end