//
//  SODeserializer.m
//  CocoaAMF
//
//  Created by Marc Bauer on 15.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "SODeserializer.h"


@implementation SODeserializer

- (NSDictionary *)deserialize
{
	// padding
	[m_stream readUInt16];
	// length
	[m_stream readUInt32];
	// signature
	[m_stream readDataWithLength:10];
	
	NSString *name = [m_stream readUTF8:[m_stream readUInt16]];
	NSLog(@"name: %@", name);
	
	// padding
	[m_stream readUInt16];
	uint16_t version = [m_stream readUInt16];
	
	AMFDeserializer *deserializer = version == 0 
		? [[AMF0Deserializer alloc] initWithStream:m_stream]
		: [[AMF3Deserializer alloc] initWithStream:m_stream];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	while ([m_stream availableBytes])
	{
		NSString *key = [deserializer readString];
		id value = [deserializer deserialize];
		[dict setObject:value forKey:key];
		// read padding byte
		[m_stream readUInt8];
	}
	
	[deserializer release];
	return dict;
}

@end