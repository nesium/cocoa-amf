//
//  AMFByteArray.h
//  RSFGameServer
//
//  Created by Marc Bauer on 22.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMF.h"
#import "ASObject.h"

#if TARGET_OS_IPHONE
#import "NSObject-iPhoneExtensions.h"
#endif

#define AMFInvalidArchiveOperationException @"AMFInvalidArchiveOperationException"

@interface AMFByteArray : NSObject 
{
	NSMutableData *m_data;
	AMFVersion m_objectEncoding;
	uint32_t m_position;
	const uint8_t *m_bytes;
}

@property (nonatomic, readonly) AMFVersion objectEncoding;
@property (nonatomic, readonly) NSData *data;

- (id)initForReadingWithData:(NSData *)data encoding:(AMFVersion)encoding;

+ (id)unarchiveObjectWithData:(NSData *)data encoding:(AMFVersion)encoding;
+ (id)unarchiveObjectWithFile:(NSString *)path encoding:(AMFVersion)encoding;

//- (void)compress;
- (BOOL)readBoolean;
- (int8_t)_decodeChar;
- (NSData *)readBytes:(uint32_t)length;
- (double)_decodeDouble;
- (float)_decodeFloat;
- (int32_t)_decodeInt;
- (NSString *)readMultiByte:(uint32_t)length encoding:(NSStringEncoding)encoding;
- (NSObject *)_decodeObject;
- (int16_t)_decodeShort;
- (uint8_t)_decodeUnsignedChar;
- (uint32_t)_decodeUnsignedInt;
- (uint16_t)_decodeUnsignedShort;
- (NSString *)_decodeUTF;
- (NSString *)_decodeUTFBytes:(uint32_t)length;
// - (void)uncompress;

@end


@interface AMF0ByteArray : AMFByteArray
{
	NSMutableArray *m_objectTable;
	AMFByteArray *m_avmPlusByteArray;
}

@end


@interface AMF3ByteArray : AMFByteArray
{
	NSMutableArray *m_stringTable;
	NSMutableArray *m_objectTable;
	NSMutableArray *m_traitsTable;
}

- (uint32_t)readUInt29;

@end


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