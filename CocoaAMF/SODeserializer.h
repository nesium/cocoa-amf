//
//  SODeserializer.h
//  CocoaAMF
//
//  Created by Marc Bauer on 15.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMFUnarchiver.h"
#import "AMFDebugUnarchiver.h"


@interface SODeserializer : NSObject
{
	BOOL useDebugUnarchiver;
}
@property (nonatomic, assign) BOOL useDebugUnarchiver;
- (NSObject *)deserialize:(NSData *)data;
@end