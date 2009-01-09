//
//  AbstractAMFTest.m
//  CocoaAMF
//
//  Created by Marc Bauer on 09.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "AbstractAMFTest.h"


@implementation AbstractAMFTest

- (void)assertAMF0Data:(const char *)data length:(uint32_t)length equalsObject:(id)obj;
{
	AMFByteArray *byteArray = [[AMFByteArray alloc] 
		initWithData:[NSData dataWithBytes:data length:length] encoding:kAMF0Version];
	id deserializedObj = [byteArray readObject];
	STAssertTrue((deserializedObj == obj || [deserializedObj isEqual:obj]), @"%@ should be %@", 
		deserializedObj, obj);
	[byteArray release];
}

@end