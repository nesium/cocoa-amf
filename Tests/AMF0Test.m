//
//  AMF0Test.m
//  CocoaAMF
//
//  Created by Marc Bauer on 09.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "AMF0Test.h"


@implementation AMF0Test

- (void)testReadNumber
{	
	[self assertAMF0Data:"\x00\x00\x00\x00\x00\x00\x00\x00\x00" length:9 
		equalsObject:[NSNumber numberWithInt:0]];
	[self assertAMF0Data:"\x00\x3f\xc9\x99\x99\x99\x99\x99\x9a" length:9 
		equalsObject:[NSNumber numberWithDouble:0.2]];
	[self assertAMF0Data:"\x00\x3f\xf0\x00\x00\x00\x00\x00\x00" length:9 
		equalsObject:[NSNumber numberWithInt:1]];
	[self assertAMF0Data:"\x00\x40\x45\x00\x00\x00\x00\x00\x00" length:9 
		equalsObject:[NSNumber numberWithInt:42]];
	[self assertAMF0Data:"\x00\xc0\x5e\xc0\x00\x00\x00\x00\x00" length:9 
		equalsObject:[NSNumber numberWithInt:-123]];
	[self assertAMF0Data:"\x00\x3f\xf3\xc0\xca\x42\x83\xde\x1b" length:9 
		equalsObject:[NSNumber numberWithDouble:1.23456789]];
}

- (void)testReadBoolean
{
	[self assertAMF0Data:"\x01\x01" length:2 
		equalsObject:[NSNumber numberWithBool:YES]];
	[self assertAMF0Data:"\x01\x00" length:2 
		equalsObject:[NSNumber numberWithBool:NO]];
}

- (void)testReadString
{
	[self assertAMF0Data:"\x02\x00\x00" length:3 
		equalsObject:@""];
	[self assertAMF0Data:"\x02\x00\x05hello" length:8 
		equalsObject:@"hello"];
	[self assertAMF0Data:"\x02\x00\t\xe1\x9a\xa0\xe1\x9b\x87\xe1\x9a\xbb" length:12 
		equalsObject:@"ᚠᛇᚻ"];
}

- (void)testReadNull
{
	[self assertAMF0Data:"\x05" length:1 equalsObject:[NSNull null]];
}

- (void)testReadUndefined
{
	[self assertAMF0Data:"\x06" length:1 equalsObject:[NSNull null]];
}

- (void)testReadArray
{
	[self assertAMF0Data:"\x0a\x00\x00\x00\x00" length:5 equalsObject:[NSArray array]];
	[self assertAMF0Data:"\x0a\x00\x00\x00\x03\x00\x3f\xf0\x00\x00\x00\x00\x00\x00\x00\x40\x00\
\x00\x00\x00\x00\x00\x00\x00\x40\x08\x00\x00\x00\x00\x00\x00" length:32 
		equalsObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:1], 
			[NSNumber numberWithInt:2], [NSNumber numberWithInt:3], nil]];
}

- (void)testReadDictionary
{
	[self assertAMF0Data:"\x03\x00\x01a\x02\x00\x01a\x00\x00\t" length:11 
		equalsObject:[NSDictionary dictionaryWithObject:@"a" forKey:@"a"]];
}


@end