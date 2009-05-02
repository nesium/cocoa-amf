//
//  SCGenerator.h
//  CocoaAMF
//
//  Created by Marc Bauer on 02.05.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMFDebugUnarchiver.h"

@protocol StubCodeGenerator
- (NSString *)stubCodeForDataNode:(AMFDebugDataNode *)node;
@end


@interface SCGenerator : NSObject
{
	NSMutableDictionary *m_generators;
}
+ (SCGenerator *)sharedGenerator;
- (void)registerGenerator:(id <StubCodeGenerator>)gen forLanguage:(NSString *)languageName;
- (NSString *)stubCodeForDataNode:(AMFDebugDataNode *)node languageName:(NSString *)languageName;
- (NSArray *)languageNames;
@end