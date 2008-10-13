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


@interface AMFKeyedArchiver : NSCoder 
{
	NSMutableData *m_data;
	AMFVersion m_version;
	NSMutableArray *m_currentStack;
}

@property (nonatomic, assign) AMFVersion version;

+ (NSData *)archivedDataWithRootObject:(id)rootObject;
- (void)finishEncoding;

@end