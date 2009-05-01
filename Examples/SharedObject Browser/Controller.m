//
//  Controller.m
//  CocoaAMF
//
//  Created by Marc Bauer on 07.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "Controller.h"


@implementation Controller

- (void)awakeFromNib
{
	m_SOFolderRep = [[FileSystemRepNode alloc] initWithPath:
		[@"~/Library/Preferences/Macromedia/Flash Player/#SharedObjects" 
			stringByExpandingTildeInPath] options:kFileSystemRepNodeOptionHideInvisibleFiles];
	[m_directoryTreeController setContent:m_SOFolderRep];
	
	m_dataSource = [[OutlineViewDataSource alloc] init];
	[m_outlineView setDataSource:m_dataSource];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	if ([m_directoryOutlineView selectedRow] == -1)
	{
		return;
	}

	NSString *path = [[[m_directoryOutlineView itemAtRow:[m_directoryOutlineView selectedRow]] 
		representedObject] path];
	if (![[[path pathExtension] lowercaseString] isEqualToString:@"sol"])
	{
		return;
	}

	SODeserializer *deserializer = [[SODeserializer alloc] init];
	deserializer.useDebugUnarchiver = YES;
	m_dataSource.rootObject = [deserializer deserialize:[NSData dataWithContentsOfFile:path]];
	[m_outlineView reloadData];
	[m_outlineView expandItem:[m_outlineView itemAtRow:0] expandChildren:YES];
	[deserializer release];
}

@end