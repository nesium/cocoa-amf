//
//  AMFActionMessage.m
//  SimpleHTTPServer
//
//  Created by Marc Bauer on 12.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "AMFActionMessage.h"

@interface AMFActionMessage (Private)
- (void)_applyData:(NSData *)data;
@end


@implementation AMFActionMessage

@synthesize version=m_version;
@synthesize headers=m_headers;
@synthesize bodies=m_bodies;


#pragma mark -
#pragma mark Initialization & Deallcation

- (id)init{
	if (self = [super init]){
		m_headers = [[NSMutableArray alloc] init];
		m_bodies = [[NSMutableArray alloc] init];
		m_version = kAMF3Encoding;
		m_useDebugUnarchiver = NO;
	}
	return self;
}

- (id)initWithData:(NSData *)data{
	if (self = [super init]){
		[self _applyData:data];
	}
	return self;
}

- (id)initWithDataUsingDebugUnarchiver:(NSData *)data{
	if (self = [super init]){
		m_useDebugUnarchiver = YES;
		[self _applyData:data];
	}
	return self;
}




#pragma mark -
#pragma mark Public methods

- (NSData *)data{
	AMFArchiver *ba = [[AMFArchiver alloc] initForWritingWithMutableData:[NSMutableData data] 
		encoding:kAMF0Encoding];
	[ba encodeUnsignedShort:m_version];
	[ba encodeUnsignedShort:[m_headers count]];
	for (AMFMessageHeader *header in m_headers){
		[ba encodeUTF:header.name];
		[ba encodeBool:header.mustUnderstand];
		AMFArchiver *headerBa = [[AMFArchiver alloc] initForWritingWithMutableData:[NSMutableData data] 
			encoding:m_version];
		if (m_version == kAMF3Encoding){
			[headerBa encodeUnsignedChar:kAMF0AVMPlusObjectType];
		}
		[headerBa encodeObject:header.data];
		[ba encodeUnsignedInt:(uint32_t)[headerBa.data length]];
		[ba encodeDataObject:headerBa.data];
	}
	[ba encodeUnsignedShort:[m_bodies count]];
	for (AMFMessageBody *body in m_bodies){
		body.targetURI != nil ? [ba encodeUTF:body.targetURI] : [ba encodeUTF:@"null"];
		body.responseURI != nil ? [ba encodeUTF:body.responseURI] : [ba encodeUTF:@"null"];
		AMFArchiver *bodyBa = [[AMFArchiver alloc] initForWritingWithMutableData:[NSMutableData data] 
			encoding:m_version];
		if (m_version == kAMF3Encoding){
			[bodyBa encodeUnsignedChar:kAMF0AVMPlusObjectType];
		}
		[bodyBa encodeObject:body.data];
		[ba encodeUnsignedInt:(uint32_t)[bodyBa.data length]];
		[ba encodeDataObject:bodyBa.data];
	}
	NSData *data = ba.data;
	
	return data;
}

- (NSUInteger)messagesCount{
	return [m_bodies count];
}

- (AMFMessageBody *)bodyAtIndex:(NSUInteger)index{
	return [m_bodies objectAtIndex:index];
}

- (AMFMessageHeader *)headerAtIndex:(NSUInteger)index{
	// we behave nicely if everyhing seems to be inside the valid bounds
	if (index >= [m_headers count] && index < [self messagesCount])
		return nil;
	return [m_headers objectAtIndex:index];
}

- (void)addBodyWithTargetURI:(NSString *)targetURI responseURI:(NSString *)responseURI data:(id)data{
	AMFMessageBody *body = [[AMFMessageBody alloc] init];
	body.targetURI = targetURI;
	body.responseURI = responseURI;
	body.data = data;
	[m_bodies addObject:body];
}

- (void)addHeaderWithName:(NSString *)name mustUnderstand:(BOOL)mustUnderstand data:(id)data{
	AMFMessageHeader *header = [[AMFMessageHeader alloc] init];
	header.name = name;
	header.mustUnderstand = mustUnderstand;
	header.data = data;
	[m_headers addObject:header];
}

- (void)mergeActionMessage:(AMFActionMessage *)message{
	[m_headers addObjectsFromArray:message.headers];
	[m_bodies addObjectsFromArray:message.bodies];
}

- (NSString *)description{
	return [NSString stringWithFormat:@"<%@ = %p | version: %d | headers: %lu bodies: %lu>\nheaders:\n%@\nbodies:\n%@", 
		[self class], self, m_version, (unsigned long)[m_headers count], (unsigned long)[m_bodies count],
		m_headers, m_bodies];
}



#pragma mark -
#pragma mark Private methods

- (void)_applyData:(NSData *)data{
	AMFUnarchiver *ba = m_useDebugUnarchiver 
		? [[AMFDebugUnarchiver alloc] initForReadingWithData:data encoding:kAMF0Encoding] 
		: [[AMFUnarchiver alloc] initForReadingWithData:data encoding:kAMF0Encoding];
	m_version = [ba decodeUnsignedShort];
	uint16_t numHeaders = [ba decodeUnsignedShort];
	NSMutableArray *headers = [NSMutableArray arrayWithCapacity:numHeaders];
	for (uint16_t i = 0; i < numHeaders; i++){
		AMFMessageHeader *header = [[AMFMessageHeader alloc] init];
		header.name = [ba decodeUTF];
		header.mustUnderstand = [ba decodeBool];
		// Header length
		[ba decodeUnsignedInt];
		header.data = [ba decodeObject];
		[headers addObject:header];
	}
	m_headers = [headers copy];
	
	uint16_t numBodies = [ba decodeUnsignedShort];
	NSMutableArray *bodies = [NSMutableArray arrayWithCapacity:numBodies];
	for (uint16_t i = 0; i < numBodies; i++){
		AMFMessageBody *body = [[AMFMessageBody alloc] init];
		body.targetURI = [ba decodeUTF];
		body.responseURI = [ba decodeUTF];
		[ba decodeUnsignedInt];
		body.data = [ba decodeObject];
		[bodies addObject:body];
	}
	m_bodies = [bodies copy];
}

@end



#pragma mark -



@implementation AMFMessageHeader

@synthesize name=m_name;
@synthesize mustUnderstand=m_mustUnderstand;
@synthesize data=m_data;


#pragma mark -
#pragma mark Initialization & Deallocation

+ (AMFMessageHeader *)messageHeaderWithName:(NSString *)name data:(NSObject *)data 
	mustUnderstand:(BOOL)mustUnderstand{
	AMFMessageHeader *header = [[AMFMessageHeader alloc] init];
	header.name = name;
	header.data = data;
	header.mustUnderstand = mustUnderstand;
	return header;
}

- (id)init{
	if (self = [super init]){
		m_name = nil;
		m_mustUnderstand = NO;
		m_data = nil;
	}
	return self;
}


- (NSString *)description{
	return [NSString stringWithFormat:@"<%@ = %p | name: %@ | mustUnderstand: %d>\n%@",
		[self class], self, m_name, m_mustUnderstand, m_data];
}

@end



#pragma mark -



@implementation AMFMessageBody

@synthesize targetURI=m_targetURI;
@synthesize responseURI=m_responseURI;
@synthesize data=m_data;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init{
	if (self = [super init]){
		m_targetURI = nil;
		m_responseURI = nil;
		m_data = nil;
	}
	return self;
}


- (NSString *)description{
	return [NSString stringWithFormat:@"<%@ = %p | targetURI: %@ | responseURI: %@>\n%@", 
		[self class], self, m_targetURI, m_responseURI, m_data];
}

@end