//
//  DirectoryService.m
//  CocoaAMF
//
//  Created by Marc Bauer on 10.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "DirectoryService.h"


@implementation DirectoryService

- (NSArray *)directoryContentsAtPath:(NSArray *)arguments
{
	NSString *path = [arguments objectAtIndex:0];
	BOOL isDir;
	if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] || !isDir)
	{
		return [NSArray array];
	}
	
	NSError *error = nil;
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path 
		error:&error];
	if (error != nil)
	{
		return [NSArray array];
	}
	return contents;
}

@end