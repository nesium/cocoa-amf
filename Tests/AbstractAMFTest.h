//
//  AbstractAMFTest.h
//  CocoaAMF
//
//  Created by Marc Bauer on 09.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "AMF.h"
#import "AMFUnarchiver.h"
#import "AMFArchiver.h"


@interface AbstractAMFTest : SenTestCase{
}
- (NSString *)fullPathForTestFile:(NSString *)file version:(AMFEncoding *)version;
- (AMFUnarchiver *)unarchiverForPath:(NSString *)path;
- (BOOL)assertDataOfFile:(NSString *)path isEqualTo:(id)obj;
- (BOOL)assertEncodedObject:(id)obj isEqualToContentsOfFile:(NSString *)path;
@end


@interface Spam : NSObject <NSCoding>{
	NSString *baz;
	NSString *x;
}
@property (nonatomic, retain) NSString *baz;
@end