//
//  SODeserializer.m
//  CocoaAMF
//
//  Created by Marc Bauer on 15.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "SODeserializer.h"


@implementation SODeserializer

- (id)deserialize
{
	uint16_t version = [m_stream readUInt16];
	uint32_t length = [m_stream readUInt32];
	NSData *signature = [m_stream readDataWithLength:10];
	
	NSString *name = [m_stream readUTF8:[m_stream readUInt16]];
	NSLog(@"name: %@", name);
	
	NSData *padding = [m_stream readDataWithLength:4];
	uint16_t keyLength = [m_stream readUInt16];
	
	AMF0Deserializer *deserializer = [[AMF0Deserializer alloc] initWithStream:m_stream];
	
	while (keyLength != 0)
	{
		NSString *key = [m_stream readUTF8:keyLength];
		id value = [deserializer deserialize];
		NSLog(@"key: %@, value: %@", key, value);
		if ([m_stream availableBytes] < 2)
		{
			break;
		}
		keyLength = [m_stream readUInt16];
	}
	
	[deserializer release];
	return nil;
}

@end