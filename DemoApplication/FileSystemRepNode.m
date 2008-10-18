//
//  FileSystemRepNode.m
//  CocoaAMF
//
//  Created by Marc Bauer on 18.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "FileSystemRepNode.h"

@interface FileSystemRepNode (Private)
- (void)collectSubpaths;
@end


@implementation FileSystemRepNode

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithPath:(NSString *)path options:(uint8_t)options
{
	if (self = [super init])
	{
		m_path = [path retain];
		m_options = options;
	}
	return self;
}

- (void)dealloc
{
	[m_path release];
	[m_subpaths release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (NSString *)path
{
	return m_path;
}

- (NSString *)name
{
	return [m_path lastPathComponent];
}

- (NSArray *)subpaths
{
	if (!m_subpaths)
	{
		[self collectSubpaths];
	}
	return m_subpaths;
}

- (NSUInteger)subpathsCount
{
	return [self.subpaths count];
}

- (BOOL)isLeaf
{
	return self.subpathsCount == 0;
}



#pragma mark -
#pragma mark Private methods

- (void)collectSubpaths
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray *subpaths = [fm directoryContentsAtPath:m_path];
	NSMutableArray *subReps = [[NSMutableArray alloc] initWithCapacity:[subpaths count]];
	
	for (NSString *path in subpaths)
	{
		NSString *fullpath = [m_path stringByAppendingPathComponent:path];
		FileSystemRepNode *subpath = [[FileSystemRepNode alloc] 
			initWithPath:fullpath options:m_options];
		if (m_options & kFileSystemRepNodeOptionHideInvisibleFiles)
		{
			NSURL *pathURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",
				[fullpath stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding]]];
			LSItemInfoRecord infoRec;
			OSStatus err=noErr;

			err = LSCopyItemInfoForURL((CFURLRef)pathURL, kLSRequestBasicFlagsOnly, &infoRec);
			if (!err && (infoRec.flags & kLSItemInfoIsInvisible))
			{
				continue;
			}
		}
		[subReps addObject:subpath];
		[subpath release];
	}
	
	m_subpaths = [subReps copy];
	[subReps release];
}

@end