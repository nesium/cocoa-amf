//
//  OutlineViewDelegate.m
//  CocoaAMF
//
//  Created by Marc Bauer on 18.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "OutlineViewDataSource.h"


@implementation OutlineViewDataSource

@synthesize rootObject=m_rootObject;

- (id)initWithRootObject:(NSObject *)rootObject
{
	if (self = [super init])
	{
		m_rootObject = [rootObject retain];
	}
	return self;
}

- (void)dealloc
{
	[m_rootObject release];
	[super dealloc];
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	if (item == nil)
	{
		item = m_rootObject;
	}
	NSLog(@"a ITEM: %@", item);
	if ([item isKindOfClass:[NSArray class]])
	{
		return [(NSArray *) item objectAtIndex:index];
	}
	else if ([item isKindOfClass:[NSDictionary class]])
	{
		return [[(NSDictionary *)item allValues] objectAtIndex:index];
	}
	else if ([item isKindOfClass:[ASObject class]])
	{
		return [[[(ASObject *)item properties] allValues] objectAtIndex:index];
	}
	
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	NSLog(@"b ITEM: %@", item);
	return (([item isKindOfClass:[NSArray class]] || [item isKindOfClass:[NSDictionary class]] || 
		[item isKindOfClass:[ASObject class]]) && [item count] > 0);
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if (item == nil)
	{
		item = m_rootObject;
	}
	NSLog(@"c ITEM: %@", item);
	return [item count];
}

- (id)outlineView:(NSOutlineView *)outlineView 
	objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	if ([[tableColumn identifier] isEqualToString:@"name"])
	{
		id parent = [outlineView parentForItem:item];
		if (parent == nil)
		{
			parent = m_rootObject;
		}
		if ([parent isKindOfClass:[NSArray class]])
		{
			return [NSString stringWithFormat:@"%i", [(NSArray *)parent indexOfObject:item]];
		}
		else if ([parent isKindOfClass:[NSDictionary class]] || 
			[parent isKindOfClass:[ASObject class]])
		{
			NSDictionary *obj = [parent isKindOfClass:[ASObject class]] 
				? [(ASObject *)parent properties]
				: (NSDictionary *)parent;
			return [[obj allKeys] objectAtIndex:[[obj allValues] indexOfObject:item]];
		}
		return @"";
	}
	else if ([[tableColumn identifier] isEqualToString:@"type"])
	{
		return ([item isKindOfClass:[ASObject class]] 
			? ([[(ASObject *)item type] length] == 0 ? @"Object" : [(ASObject *)item type])
			: [item className]);
	}
	else if ([[tableColumn identifier] isEqualToString:@"value"])
	{
		if ([item isKindOfClass:[NSString class]])
		{
			return item;
		}
		else if ([item isKindOfClass:[NSNumber class]])
		{
			return [(NSNumber *)item stringValue];
		}
		else if (item == [NSNull null])
		{
			return @"null";
		}
		return @"";
	}
	
	return nil;
}

@end