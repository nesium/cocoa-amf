//
//  AMFMutableByteArray.h
//  CocoaAMF
//
//  Created by Marc Bauer on 13.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMFByteArray.h"


@interface AMFMutableByteArray : AMFByteArray 
{
	NSMutableData *m_data;
}

//--------------------------------------------------------------------------------------------------
//	Usual NSCoder methods
//--------------------------------------------------------------------------------------------------

- (id)initForWritingWithMutableData:(NSMutableData *)data encoding:(AMFVersion)encoding;
+ (NSData *)archivedDataWithRootObject:(id)rootObject;
+ (BOOL)archiveRootObject:(id)rootObject toFile:(NSString *)path;

- (void)encodeBool:(BOOL)value forKey:(NSString *)key;
- (void)encodeBytes:(const void *)address length:(NSUInteger)length forKey:(NSString *)key;
- (void)encodeDouble:(double)value forKey:(NSString *)key;
- (void)encodeFloat:(float)value forKey:(NSString *)key;
- (void)encodeInt32:(int32_t)value forKey:(NSString *)key;
- (void)encodeInt64:(int64_t)value forKey:(NSString *)key;
- (void)encodeInt:(int)value forKey:(NSString *)key;
- (void)encodeObject:(id)value forKey:(NSString *)key;
- (void)encodeValueOfObjCType:(const char *)valueType at:(const void *)address;
- (void)encodeValuesOfObjCTypes:(const char *)valueTypes, ...;

//--------------------------------------------------------------------------------------------------
//	AMF Extensions for writing specific data and serializing externalizable classes
//--------------------------------------------------------------------------------------------------

- (void)encodeBoolean:(BOOL)value;
- (void)encodeChar:(int8_t)value;
- (void)encodeDouble:(double)value;
- (void)encodeFloat:(float)value;
- (void)encodeInt:(int32_t)value;
- (void)encodeShort:(int16_t)value;
- (void)encodeUnsignedChar:(uint8_t)value;
- (void)encodeUnsignedInt:(uint32_t)value;
- (void)encodeUnsignedShort:(uint16_t)value;
- (void)encodeUnsignedInt29:(uint32_t)value;
- (void)encodeBytes:(NSData *)value;
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