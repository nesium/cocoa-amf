//
//  TestObject.m
//  SimpleHTTPServer
//
//  Created by Marc Bauer on 12.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "TestObject.h"


@implementation TestObject

- (id)initWithCoder:(NSCoder *)enc
{
	if (self = [super init])
	{
		[enc decodeObjectForKey:@"a"];
		[enc decodeObjectForKey:@"b"];
		[enc decodeObjectForKey:@"c"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)enc
{
	[enc encodeObject:@"value a" forKey:@"a"];
	[enc encodeObject:@"value b" forKey:@"b"];
	[enc encodeObject:@"value c" forKey:@"c"];
	[enc encodeObject:[NSArray arrayWithObjects:@"1", @"2", @"3", nil] forKey:@"d"];
	[enc encodeBool:NO forKey:@"e"];
	[enc encodeObject:[NSDate date] forKey:@"f"];
}

@end