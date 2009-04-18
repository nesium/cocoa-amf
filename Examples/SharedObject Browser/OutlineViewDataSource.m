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
	if (rootObject != nil)
	{
		rootObject = [NSArray arrayWithObject:rootObject];
	}
	[rootObject retain];
	[m_rootObject release];
	m_rootObject = rootObject;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	if (item == nil)
	{
		item = m_rootObject;
	}
	if ([item isKindOfClass:[NSArray class]])
	{
		return [(NSArray *)item objectAtIndex:index];
	}
	else if ([item isKindOfClass:[NSDictionary class]])
	{
		return [[(NSDictionary *)item allValues] objectAtIndex:index];
	}
	else if ([item isKindOfClass:[ASObject class]])
	{
		return [[[(ASObject *)item properties] allValues] objectAtIndex:index];
	}
	else if ([item isKindOfClass:[FlexArrayCollection class]])
	{
		return [[(FlexArrayCollection *)item source] objectAtIndex:index];
	}
	
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	return (([item isKindOfClass:[NSArray class]] || [item isKindOfClass:[NSDictionary class]] || 
		[item isKindOfClass:[ASObject class]] || [item isKindOfClass:[FlexArrayCollection class]]) && 
		[item count] > 0);
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if (item == nil)
	{
		item = m_rootObject;
	}
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
		else if ([parent isKindOfClass:[FlexObjectProxy class]])
		{
			parent = [(FlexObjectProxy *)parent object];
		}
		
		if ([parent isKindOfClass:[NSArray class]] || 
			[parent isKindOfClass:[FlexArrayCollection class]])
		{
			if (parent == m_rootObject)
			{
				return @"Parameters";
			}
			NSArray *arr = [parent isKindOfClass:[FlexArrayCollection class]] 
				? [(FlexArrayCollection *)parent source] 
				: (NSArray *)parent;
			return [NSString stringWithFormat:@"%i", [arr indexOfObject:item]];
		}
		else if ([parent isKindOfClass:[NSDictionary class]] || 
			[parent isKindOfClass:[ASObject class]])
		{
			NSDictionary *obj = [parent isKindOfClass:[ASObject class]] 
				? [(ASObject *)parent properties]
				: (NSDictionary *)parent;
			return [[obj allKeys] objectAtIndex:[[obj allValues] indexOfObjectIdenticalTo:item]];
		}
		return @"";
	}
	else if ([[tableColumn identifier] isEqualToString:@"type"])
	{
		return [self classNameForObject:item];
	}
	else if ([[tableColumn identifier] isEqualToString:@"value"])
	{
		return [self valueForObject:item];
	}
	
	return nil;
}

- (NSString *)classNameForObject:(id)item
{
	if ([item isKindOfClass:[ASObject class]])
	{
		return ([[(ASObject *)item type] length] == 0 ? @"Object" : [(ASObject *)item type]);
	}
	else if ([item isKindOfClass:[FlexArrayCollection class]])
	{
		return @"ArrayCollection";
	}
	else if ([item isKindOfClass:[FlexObjectProxy class]])
	{
		return @"FlexProxyObject";
	}
	else if ([item isKindOfClass:[NSString class]])
	{
		return @"String";
	}
	else if ([item isKindOfClass:[NSArray class]])
	{
		return @"Array";
	}
	else if ([item isKindOfClass:[NSDictionary class]])
	{
		return @"Mixed Array";
	}
	else if ([[item className] isEqualToString:@"NSCFBoolean"])
	{
		return @"Boolean";
	}
	else if ([item isKindOfClass:[NSNumber class]])
	{
		return @"Number";
	}
	else if ([item isKindOfClass:[NSNull class]])
	{
		return @"null";
	}
	else if ([item isKindOfClass:[NSDate class]])
	{
		return @"Date";
	}
	return [item className];
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