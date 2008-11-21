//
//  AMF3TraitsInfo.h
//  CocoaAMF
//
//  Created by Marc Bauer on 07.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMF3TraitsInfo : NSObject 
{
	NSString *m_className;
	BOOL m_dynamic;
	BOOL m_externalizable;
	NSUInteger m_count;
	NSMutableArray *m_properties;
}

@property (nonatomic, retain) NSString *className;
@property (nonatomic, assign) BOOL dynamic;
@property (nonatomic, assign) BOOL externalizable;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, retain) NSMutableArray *properties;

- (void)addProperty:(NSString *)property;

@end