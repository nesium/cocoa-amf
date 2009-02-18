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
		AMFUnarchiver *ba = [[AMFUnarchiver alloc] initWithData:data encoding:kAMF0Version];
		m_version = [ba decodeUnsignedShort];
		uint16_t numHeaders = [ba decodeUnsignedShort];
		NSMutableArray *headers = [NSMutableArray arrayWithCapacity:numHeaders];
		for (uint16_t i = 0; i < numHeaders; i++)
		{
			AMFMessageHeader *header = [[AMFMessageHeader alloc] init];
			header.name = [ba decodeUTF];
			header.mustUnderstand = [ba decodeBool];
			// Header length
			[ba decodeUnsignedInt];
			header.data = [ba decodeObject];
			[headers addObject:header];
			[header release];
		}
		m_headers = [headers copy];
		
		uint16_t numBodies = [ba decodeUnsignedShort];
		NSMutableArray *bodies = [NSMutableArray arrayWithCapacity:numBodies];
		for (uint16_t i = 0; i < numBodies; i++)
		{
			AMFMessageBody *body = [[AMFMessageBody alloc] init];
			body.targetURI = [ba decodeUTF];
			body.responseURI = [ba decodeUTF];
			// Body length
			[ba decodeUnsignedInt];
			body.data = [ba decodeObject];
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
	AMFArchiver *ba = [[AMFArchiver alloc] initForWritingWithMutableData:[NSMutableData data] 
		encoding:kAMF0Version];
	[ba encodeUnsignedShort:m_version];
	[ba encodeUnsignedShort:[m_headers count]];
	for (AMFMessageHeader *header in m_headers)
	{
		[ba encodeUTF:header.name];
		[ba encodeBool:header.mustUnderstand];
		AMFArchiver *headerBa = [[AMFArchiver alloc] initForWritingWithMutableData:[NSMutableData data] 
			encoding:m_version];
		if (m_version == kAMF3Version)
		{
			[headerBa encodeUnsignedChar:kAMF0AVMPlusObjectType];
		}
		[headerBa encodeObject:header.data];
		[ba encodeUnsignedInt:[headerBa.data length]];
		[ba encodeDataObject:headerBa.data];
		[headerBa release];
	}
	[ba encodeUnsignedShort:[m_bodies count]];
	for (AMFMessageBody *body in m_bodies)
	{
		body.targetURI != nil ? [ba encodeUTF:body.targetURI] : [ba encodeUTF:@"null"];
		body.responseURI != nil ? [ba encodeUTF:body.responseURI] : [ba encodeUTF:@"null"];
		AMFArchiver *bodyBa = [[AMFArchiver alloc] initForWritingWithMutableData:[NSMutableData data] 
			encoding:m_version];
		if (m_version == kAMF3Version)
		{
			[bodyBa encodeUnsignedChar:kAMF0AVMPlusObjectType];
		}
		[bodyBa encodeObject:body.data];
		[ba encodeUnsignedInt:[bodyBa.data length]];
		[ba encodeDataObject:bodyBa.data];
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