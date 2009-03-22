//
//  SODeserializer.m
//  CocoaAMF
//
//  Created by Marc Bauer on 15.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "SODeserializer.h"


@implementation SODeserializer

- (NSDictionary *)deserialize:(NSData *)data
{
	AMFUnarchiver *headerUnarchiver = [[AMFUnarchiver alloc] initForReadingWithData:data 
		encoding:kAMF0Version];

	// padding
	[headerUnarchiver decodeUnsignedShort];
	// length
	[headerUnarchiver decodeUnsignedInt];
	// signature
	[headerUnarchiver decodeBytes:10];
	// name
	[headerUnarchiver decodeUTF];
	// padding
	[headerUnarchiver decodeUnsignedShort];
	
	uint16_t version = [headerUnarchiver decodeUnsignedShort];
	
	AMFUnarchiver *bodyUnarchiver = [headerUnarchiver retain];
	if (version == kAMF3Version)
	{
		NSUInteger startOffset = [data length] - [headerUnarchiver bytesAvailable];
		bodyUnarchiver = [[AMFUnarchiver alloc] initForReadingWithData:
			[data subdataWithRange:(NSRange){startOffset, [headerUnarchiver bytesAvailable]}]  
			encoding:kAMF3Version];
	}
	[headerUnarchiver release];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	while (![bodyUnarchiver isAtEnd])
	{
		NSString *key = [bodyUnarchiver decodeUTF];
		id value = [bodyUnarchiver decodeObject];
		[dict setObject:value forKey:key];
		// read padding byte
		[bodyUnarchiver decodeUnsignedChar];
	}
	[bodyUnarchiver release];
	return dict;
}

@end