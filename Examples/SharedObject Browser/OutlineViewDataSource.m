//
//  OutlineViewDelegate.m
//  CocoaAMF
//
//  Created by Marc Bauer on 18.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "OutlineViewDataSource.h"

@interface OutlineViewDataSource (Private)
- (NSString *)classNameForObject:(id)item;
@end


@implementation OutlineViewDataSource

@synthesize rootObject=m_rootObject;

- (id)initWithRootObject:(NSObject *)rootObject
{
	if (self = [super init])
	{
		m_rootObject = m_rootObject != nil ? [[NSArray arrayWithObject:rootObject] retain] : nil;
	}
	return self;
}

- (void)dealloc
{
	[m_rootObject release];
	[super dealloc];
}



- (void)setRootObject:(NSObject *)rootObject
{
	[rootObject retain];
	[m_rootObject release];
	m_rootObject = rootObject;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	if (item == nil)
		return m_rootObject;
	return [[(AMFDebugDataNode *)item children] objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	return [(AMFDebugDataNode *)item hasChildren];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if (item == nil && m_rootObject != nil)
		return 1;
	return [(AMFDebugDataNode *)item numChildren];
}

- (id)outlineView:(NSOutlineView *)outlineView 
	objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	if ([[tableColumn identifier] isEqualToString:@"name"])
	{
		if (item == m_rootObject)
			return @"Parameters";
		return [(AMFDebugDataNode *)item name];
	}
	else if ([[tableColumn identifier] isEqualToString:@"type"])
	{
		return [(AMFDebugDataNode *)item AMFClassName];
	}
	else if ([[tableColumn identifier] isEqualToString:@"value"])
	{
		return [self valueForObject:[(AMFDebugDataNode *)item data]];
	}
	
	return nil;
}

- (NSString *)valueForObject:(id)item
{
	if ([item isKindOfClass:[NSString class]])
	{
		return item;
	}
	else if ([[item className] isEqualToString:@"NSCFBoolean"])
	{
		return [item boolValue] ? @"true" : @"false";
	}
	else if ([item isKindOfClass:[NSNumber class]])
	{
		return [(NSNumber *)item stringValue];
	}
	else if ([item isKindOfClass:[NSDate class]])
	{
		return [(NSDate *)item description];
	}
	return @"";
}

@end