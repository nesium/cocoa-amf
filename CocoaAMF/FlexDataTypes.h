//
//  AMFFlexDataTypes.h
//  CocoaAMF
//
//  Created by Marc Bauer on 23.03.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FlexArrayCollection : NSObject <NSCoding>
{
	NSArray *source;
}
@property (nonatomic, retain) NSArray *source;
- (id)initWithSource:(NSArray *)obj;
@end

@interface FlexObjectProxy : NSObject <NSCoding>
{
	NSObject *object;
}
@property (nonatomic, retain) NSObject *object;
- (id)initWithObject:(NSObject *)obj;
@end