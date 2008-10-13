//
//  AMFMessageHeader.m
//  SimpleHTTPServer
//
//  Created by Marc Bauer on 11.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "AMFMessageHeader.h"


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