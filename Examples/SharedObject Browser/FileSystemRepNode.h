//
//  FileSystemRepNode.h
//  CocoaAMF
//
//  Created by Marc Bauer on 18.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kFileSystemRepNodeOptionHideInvisibleFiles 1

@interface FileSystemRepNode : NSObject 
{
	NSString *m_path;
	NSArray *m_subpaths;
	uint8_t m_options;
}

@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSArray *subpaths;
@property (nonatomic, readonly) NSUInteger subpathsCount;
@property (nonatomic, readonly) BOOL isLeaf;

- (id)initWithPath:(NSString *)path options:(uint8_t)options;

@end