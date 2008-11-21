//
//  AMF3TraitsInfo.m
//  CocoaAMF
//
//  Created by Marc Bauer on 07.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "AMF3TraitsInfo.h"


@implementation AMF3TraitsInfo

@synthesize className=m_className;
@synthesize dynamic=m_dynamic;
@synthesize externalizable=m_externalizable;
@synthesize count=m_count;
@synthesize properties=m_properties;


#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init
{
	if (self = [super init])
	{
		m_properties = [[NSMutableArray alloc] init];
		m_dynamic = NO;
		m_externalizable = NO;
	}
	return self;
}

- (void)dealloc
{
	[m_className release];
	[m_properties release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)addProperty:(NSString *)property
{
	[m_properties addObject:property];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ = 0x%08X | className: %@ | dynamic: %d \
| externalizable: %d | count: %d>", 
		[self class], (long)self, m_className, m_dynamic, m_externalizable, m_count];
}

@end