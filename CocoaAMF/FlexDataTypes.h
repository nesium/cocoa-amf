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
- (NSUInteger)count;
@end


@interface FlexObjectProxy : NSObject <NSCoding>
{
	NSObject *object;
}
@property (nonatomic, retain) NSObject *object;
- (id)initWithObject:(NSObject *)obj;
@end


@interface FlexAbstractMessage : NSObject <NSCoding>
{
	NSObject *body;
	NSString *clientId;
	NSString *destination;
	NSDictionary *headers;
	NSString *messageId;
	NSTimeInterval timeToLive;
	NSTimeInterval timestamp;
}
@property (nonatomic, retain) NSObject *body;
@property (nonatomic, retain) NSString *clientId;
@property (nonatomic, retain) NSString *destination;
@property (nonatomic, retain) NSDictionary *headers;
@property (nonatomic, retain) NSString *messageId;
@property (nonatomic, assign) NSTimeInterval timeToLive;
@property (nonatomic, assign) NSTimeInterval timestamp;
@end


@interface FlexAsyncMessage : FlexAbstractMessage
{
	NSString *correlationId;
}
@property (nonatomic, retain) NSString *correlationId;
@end


@interface FlexCommandMessage : FlexAsyncMessage
{
	uint16_t operation;
}
@property (nonatomic, assign) uint16_t operation;
@end


@interface FlexAcknowledgeMessage : FlexAsyncMessage
{
}
@end


@interface FlexErrorMessage : FlexAcknowledgeMessage
{
	NSObject *extendedData;
	NSString *faultCode;
	NSString *faultDetail;
	NSString *faultString;
	NSObject *rootCause;
}
@property (nonatomic, retain) NSObject *extendedData;
@property (nonatomic, retain) NSString *faultCode;
@property (nonatomic, retain) NSString *faultDetail;
@property (nonatomic, retain) NSString *faultString;
@property (nonatomic, retain) NSObject *rootCause;
@end


@interface FlexRemotingMessage : FlexAbstractMessage
{
	NSString *operation;
	NSString *source;
}
@property (nonatomic, retain) NSString *operation;
@property (nonatomic, retain) NSString *source;
@end