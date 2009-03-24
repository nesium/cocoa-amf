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
	BOOL m_isExternalizable;
	NSMutableDictionary *m_properties;
	NSData *m_data;
}
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSMutableDictionary *properties;
@property (nonatomic, assign) BOOL isExternalizable;
@property (nonatomic, retain) NSData *data;

+ (ASObject *)asObjectWithDictionary:(NSDictionary *)dict;
- (NSUInteger)count;

@end