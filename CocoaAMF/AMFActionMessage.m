//
//  AMFActionMessage.m
//  SimpleHTTPServer
//
//  Created by Marc Bauer on 12.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "AMFActionMessage.h"


@implementation AMFActionMessage

@synthesize version=m_version;
@synthesize headers=m_headers;
@synthesize bodies=m_bodies;


#pragma mark -
#pragma mark Initialization & Deallcation

- (id)init
{
	if (self = [super init])
	{
		m_headers = nil;
		m_bodies = nil;
	}
	return self;
}

- (void)dealloc
{
	[m_headers release];
	[m_bodies release];
	[super dealloc];
}

@end