//
//  ASObject.h
//  CocoaAMF
//
//  Created by Marc Bauer on 09.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ASObject : NSObject{
	NSString *m_type;
	BOOL m_isExternalizable;
	NSMutableDictionary *m_properties;
	NSMutableArray *m_data;
}
@property (nonatomic) NSString *type;
@property (nonatomic, assign) BOOL isExternalizable;
@property (nonatomic) NSMutableDictionary *properties;
@property (nonatomic) NSMutableArray *data;
+ (ASObject *)asObjectWithDictionary:(NSDictionary *)dict;
- (void)addObject:(id)obj;
- (NSUInteger)count;
@end