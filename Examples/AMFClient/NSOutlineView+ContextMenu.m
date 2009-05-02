//
//  NSOutlineView+ContextMenu.m
//  CocoaAMF
//
//  Created by Marc Bauer on 02.05.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "NSOutlineView+ContextMenu.h"


@implementation NSOutlineView (ContextMenu)

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	int rowIndex = [self rowAtPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];

	if (rowIndex >= 0)
	{
		// There seems to be a bug in AppKit; selectRow is supposed to
		// abort editing, but it doesn't, thus we do it manually.
		[self abortEditing];
		id item = [self itemAtRow:rowIndex];	
		if (item)
		{
			id obj = [self delegate];
			if ([obj respondsToSelector:@selector(outlineView:shouldSelectItem:)] && 
				[obj outlineView:self shouldSelectItem:item])
			{
				[self selectRow:rowIndex byExtendingSelection:NO];
			}

			if ([obj respondsToSelector:@selector(outlineView:contextMenuForItem:)])
			{
				return [obj outlineView:self contextMenuForItem:item];
			}
		}
	}
	else // click in lala land
	{
		[self deselectAll:self];
		return [self menu];
	}
	return nil;
}

@end