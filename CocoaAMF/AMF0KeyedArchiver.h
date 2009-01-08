//
//  AMFCoder.h
//  SimpleHTTPServer
//
//  Created by Marc Bauer on 12.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CFNumber.h>
#import <Foundation/NSObjCRuntime.h>
#import "AMF.h"
#import "ASObject.h"
#import "AMFByteArray.h"


@interface AMF0KeyedArchiver : NSCoder 
{
	AMFByteArray *m_byteArray;
	NSMutableArray *m_currentStack;
}

- (id)initForWritingWithByteArray:(AMFByteArray *)byteArray;
+ (NSData *)archivedDataWithRootObject:(id)rootObject;
- (void)finishEncoding;

@end