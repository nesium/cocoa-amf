//
//  AMFMutableByteArray.h
//  CocoaAMF
//
//  Created by Marc Bauer on 13.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ASObject.h"


@interface AMFMutableByteArray : NSCoder 
{
	NSMutableData *m_data;
	const uint8_t *m_bytes;
	uint32_t m_position;
	NSMutableArray *m_objectTable;
	ASObject *m_currentSerializedObject;
}

//--------------------------------------------------------------------------------------------------
//	Usual NSCoder methods
//--------------------------------------------------------------------------------------------------

- (id)initForWritingWithMutableData:(NSMutableData *)data encoding:(AMFVersion)encoding;
+ (NSData *)archivedDataWithRootObject:(id)rootObject;
+ (BOOL)archiveRootObject:(id)rootObject toFile:(NSString *)path;

- (void)encodeBool:(BOOL)value forKey:(NSString *)key;
- (void)encodeDouble:(double)value forKey:(NSString *)key;
- (void)encodeFloat:(float)value forKey:(NSString *)key;
- (void)encodeInt32:(int32_t)value forKey:(NSString *)key;
- (void)encodeInt64:(int64_t)value forKey:(NSString *)key;
- (void)encodeInt:(int)value forKey:(NSString *)key;
- (void)encodeObject:(id)value forKey:(NSString *)key;

//--------------------------------------------------------------------------------------------------
//	AMF Extensions for writing specific data and serializing externalizable classes
//--------------------------------------------------------------------------------------------------

- (void)encodeBool:(BOOL)value;
- (void)encodeChar:(int8_t)value;
- (void)encodeDouble:(double)value;
- (void)encodeFloat:(float)value;
- (void)encodeInt:(int32_t)value;
- (void)encodeShort:(int16_t)value;
- (void)encodeUnsignedChar:(uint8_t)value;
- (void)encodeUnsignedInt:(uint32_t)value;
- (void)encodeUnsignedShort:(uint16_t)value;
- (void)encodeUnsignedInt29:(uint32_t)value;
- (void)encodeDataObject:(NSData *)value;
- (void)encodeMultiByteString:(NSString *)value encoding:(NSStringEncoding)encoding;
- (void)encodeObject:(NSObject *)value;
- (void)encodeUTF:(NSString *)value;
- (void)encodeUTFBytes:(NSString *)value;
@end


@interface AMF0MutableByteArray : AMFMutableByteArray
{
	NSMutableArray *m_objectTable;
	AMFByteArray *m_avmPlusByteArray;
}
@end


@interface AMF3MutableByteArray : AMFMutableByteArray
{
	NSMutableArray *m_stringTable;
	NSMutableArray *m_objectTable;
	NSMutableArray *m_traitsTable;
}
@end