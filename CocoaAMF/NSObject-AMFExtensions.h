//
//  NSObject-AMFExtensions.h
//  CocoaAMF
//
//  Created by Marc Bauer on 10.04.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMF.h"
#import "NSInvocation-AMFExtensions.h"


@interface NSObject (AMFExtensions)
+ (NSString *)uuid;
- (id)invokeMethodWithName:(NSString *)methodName arguments:(NSArray *)arguments 
	error:(NSError **)error;
- (id)invokeMethodWithName:(NSString *)methodName arguments:(NSArray *)arguments 
	error:(NSError **)error prependName:(NSString *)nameToPrepend 
	argument:(id)argumentToPrepend;
@end