//
//  SimpleMessage.m
//  CocoaAMF
//
//  Created by Marc Bauer on 29.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "SimpleMessage.h"


@implementation SimpleMessage

@synthesize message;

- (void)dealloc
{
	[message release];
	[super dealloc];
}

#pragma mark -
#pragma mark Partial NSCoder protocol methods for AMF serialization

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:message forKey:@"message"];
}

@end