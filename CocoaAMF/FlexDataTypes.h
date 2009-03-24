//
//  AMFFlexDataTypes.h
//  CocoaAMF
//
//  Created by Marc Bauer on 23.03.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMFUnarchiver.h"


@interface FlexArrayCollection : NSObject <NSCoding>
{
	NSObject *source;
}
@property (nonatomic, retain) NSObject *source;
- (id)initWithSource:(NSObject *)obj;
@end

@interface FlexObjectProxy : NSObject <NSCoding>
{
	NSObject *object;
}
@property (nonatomic, retain) NSObject *object;
- (id)initWithObject:(NSObject *)obj;
@end