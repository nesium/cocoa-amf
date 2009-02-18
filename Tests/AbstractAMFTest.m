//
//  AbstractAMFTest.m
//  CocoaAMF
//
//  Created by Marc Bauer on 09.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "AbstractAMFTest.h"

#define TEST_DATA_PATH @"../../Tests/data"


@implementation AbstractAMFTest

- (BOOL)assertDataOfFile:(NSString *)path isEqualTo:(id)obj
{
	path = [[TEST_DATA_PATH stringByAppendingPathComponent:[path pathExtension]] 
		stringByAppendingPathComponent:path];
	AMFVersion version = [[[path pathExtension] lowercaseString] isEqual:@"amf0"] 
		? kAMF0Version : kAMF3Version;
	id deserializedObj = [AMFUnarchiver unarchiveObjectWithFile:path encoding:version];
	BOOL isEqual = obj == nil ? deserializedObj == nil : [deserializedObj isEqual:obj];
	if (!isEqual) NSLog(@"Assertion failure: %@ should be %@", deserializedObj, obj);
	return isEqual;
}

- (BOOL)assertEncodedObject:(id)obj isEqualToContentsOfFile:(NSString *)path
{
	path = [[TEST_DATA_PATH stringByAppendingPathComponent:[path pathExtension]] 
		stringByAppendingPathComponent:path];
	AMFVersion version = [[[path pathExtension] lowercaseString] isEqual:@"amf0"] 
		? kAMF0Version : kAMF3Version;
	NSData *data = [AMFArchiver archivedDataWithRootObject:obj encoding:version];
	NSLog(@"%@", data);
	return [[NSData dataWithContentsOfFile:path] isEqual:data];
}

@end