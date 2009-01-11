//
//  ASObject.h
//  CocoaAMF
//
//  Created by Marc Bauer on 09.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ASObject : NSObject
{
	NSString *m_type;
	NSMutableDictionary *m_properties;
}

@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSMutableDictionary *properties;

+ (ASObject *)asObjectWithDictionary:(NSDictionary *)dict;
- (NSUInteger)count;

@end