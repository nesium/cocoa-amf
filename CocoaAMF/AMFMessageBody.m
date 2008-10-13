//
//  AMFMessageBody.m
//  SimpleHTTPServer
//
//  Created by Marc Bauer on 11.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "AMFMessageBody.h"


@implementation AMFMessageBody

@synthesize targetURI=m_targetURI;
@synthesize responseURI=m_responseURI;
@synthesize data=m_data;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init
{
	if (self = [super init])
	{
		m_targetURI = nil;
		m_responseURI = nil;
		m_data = nil;
	}
	return self;
}

- (void)dealloc
{
	[m_targetURI release];
	[m_responseURI release];
	[m_data release];
	[super dealloc];
}

@end