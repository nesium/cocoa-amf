//
//  OutlineViewDelegate.h
//  CocoaAMF
//
//  Created by Marc Bauer on 18.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ASObject.h"


@interface OutlineViewDataSource : NSObject 
{
	NSObject *m_rootObject;
}

@property (nonatomic, retain) NSObject *rootObject;

- (id)initWithRootObject:(NSObject *)rootObject;

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView 
	objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;

- (NSString *)valueForObject:(id)item;

@end