//
//  AMF3KeyedArchiver.m
//  RSFGameServer
//
//  Created by Marc Bauer on 24.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "AMF3KeyedArchiver.h"

@interface AMF3KeyedArchiver (Private)
- (void)writeObject:(id)obj;
- (void)writeArray:(NSArray *)array;
@end



@implementation AMF3KeyedArchiver

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initForWritingWithMutableData:(NSMutableData *)data
{
	if (self = [super init])
	{
		m_byteArray = [[AMFByteArray alloc] initWithData:data encoding:kAMF3Version];
		m_currentStack = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initForWritingWithByteArray:(AMFByteArray *)byteArray
{
	if (self = [super init])
	{
		m_byteArray = [byteArray retain];
		m_currentStack = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}



#pragma mark -
#pragma mark Private methods

- (void)writeObject:(id)obj
{
	if ([obj isKindOfClass:[NSString class]])
	{
		[(AMF3ByteArray *)m_byteArray writeString:(NSString *)obj omitType:NO];
	}
	else if ([obj isKindOfClass:[NSArray class]])
	{
		[(AMF3ByteArray *)m_byteArray writeArray:(NSArray *)obj];
	}
	else if ([obj isKindOfClass:[NSDictionary class]])
	{
		[(AMF3ByteArray *)m_byteArray writeDictionary:(NSDictionary *)obj];
	}
	else if ([obj isKindOfClass:[NSDate class]])
	{
		[(AMF3ByteArray *)m_byteArray writeDate:(NSDate *)obj];
	}
	else if ([obj isKindOfClass:[NSNumber class]])
	{
		[(AMF3ByteArray *)m_byteArray writeNumber:(NSNumber *)obj];
	}
	else if ([obj isKindOfClass:[ASObject class]])
	{
		[(AMF3ByteArray *)m_byteArray writeASObject:(ASObject *)obj];
	}
	else
	{
		[self encodeObject:obj forKey:nil];
	}
}


@end