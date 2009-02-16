//
//  ASObject.m
//  CocoaAMF
//
//  Created by Marc Bauer on 09.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "ASObject.h"


@implementation ASObject

@synthesize type=m_type, properties=m_properties, isExternalizable=m_isExternalizable;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init
{
	if (self = [super init])
	{
		m_properties = [[NSMutableDictionary alloc] init];
		m_type = @"";
	}
	return self;
}

+ (ASObject *)asObjectWithDictionary:(NSDictionary *)dict
{
	ASObject *obj = [[[ASObject alloc] init] autorelease];
	for (NSString *key in dict)
	{
		[obj setValue:[dict valueForKey:key] forKey:key];
	}
	return obj;
}

- (void)dealloc
{
	[m_type release];
	[m_properties release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)setValue:(id)value forKey:(NSString *)key
{
	[m_properties setValue:value forKey:key];
}

- (id)valueForKey:(NSString *)key
{
	return [m_properties valueForKey:key];
}

- (NSUInteger)count
{
	return [m_properties count];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ = 0x%08X | type: %@>\n%@", 
		[self class], (long)self, m_type, m_properties];
}

@end