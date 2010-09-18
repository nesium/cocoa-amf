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

- (BOOL)assertDataOfFile:(NSString *)path isEqualTo:(id)obj{
	AMFEncoding version;
	path = [self fullPathForTestFile:path version:&version];
	id deserializedObj = [AMFUnarchiver unarchiveObjectWithFile:path encoding:version];
	BOOL isEqual = (obj == nil) ? deserializedObj == nil : [deserializedObj isEqual:obj];
	if (!isEqual) NSLog(@"Assertion failure: %@ should be %@", deserializedObj, obj);
	return isEqual;
}

- (BOOL)assertEncodedObject:(id)obj isEqualToContentsOfFile:(NSString *)path{
	AMFEncoding version;
	path = [self fullPathForTestFile:path version:&version];

	NSData *data = [AMFArchiver archivedDataWithRootObject:obj encoding:version];
	BOOL isEqual = [[NSData dataWithContentsOfFile:path] isEqual:data];
	
	if (!isEqual){
		[data writeToFile:[[@"~/Desktop" stringByExpandingTildeInPath] stringByAppendingPathComponent:
			[path lastPathComponent]] atomically:NO];
	}
	return isEqual;
}

- (AMFUnarchiver *)unarchiverForPath:(NSString *)path{
	AMFEncoding version;
	path = [self fullPathForTestFile:path version:&version];
	AMFUnarchiver *unarchiver = [[AMFUnarchiver alloc] 
		initForReadingWithData:[NSData dataWithContentsOfFile:path] encoding:version];
	return [unarchiver autorelease];
}

- (NSString *)fullPathForTestFile:(NSString *)file version:(AMFEncoding *)version{
	if (version != nil){
		*version = [[[file pathExtension] lowercaseString] isEqual:@"amf0"] 
			? kAMF0Encoding : kAMF3Encoding;
	}
	NSString *testDataPath = [[[[NSBundle bundleForClass:[self class]] bundlePath] 
		stringByDeletingLastPathComponent] stringByAppendingPathComponent:[[TEST_DATA_PATH 
			stringByAppendingPathComponent:[file pathExtension]] 
			stringByAppendingPathComponent:file]];
	return testDataPath;
}

@end


@implementation Spam
@synthesize baz;

- (void)dealloc{
	[baz release];
	[super dealloc];
}

- (BOOL)isEqual:(id)obj{
	if (![obj isMemberOfClass:[Spam class]]) return NO;
	return [[(Spam *)obj baz] isEqual:baz];
}

- (id)initWithCoder:(NSCoder *)coder{
	if (self = [super init]){
		self.baz = [coder decodeObjectForKey:@"baz"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:baz forKey:@"baz"];
}

@end