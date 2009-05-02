//
//  NSOutlineView+ContextMenu.h
//  CocoaAMF
//
//  Created by Marc Bauer on 02.05.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSOutlineView (ContextMenu)
@end

@interface NSObject (NSOutlineViewContextMenuDelegate)
- (NSMenu *)outlineView:(NSOutlineView *)outlineView contextMenuForItem:(id)item;
@end