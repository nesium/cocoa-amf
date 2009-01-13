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

}

- (void)writeUnsignedByte:(uint8_t)value;
- (void)writeUnsignedShort:(uint16_t)value;

- (void)writeBoolean:(BOOL)value;
- (void)writeByte:(int8_t)value;
- (void)writeBytes:(NSData *)value;
- (void)writeDouble:(double)value;
- (void)writeFloat:(float)value;
- (void)writeInt:(int32_t)value;
- (void)writeMultiByte:(NSString *)value encoding:(NSStringEncoding)encoding;
- (void)writeObject:(NSObject *)value;
- (void)writeShort:(int16_t)value;
- (void)writeUnsignedInt:(uint32_t)value;
- (void)writeUTF:(NSString *)value;
- (void)writeUTFBytes:(NSString *)value;

@end


@interface AMF0MutableByteArray : AMFByteArray
{
	NSMutableArray *m_objectTable;
	AMFByteArray *m_avmPlusByteArray;
}

- (void)writeString:(NSString *)value omitType:(BOOL)omitType;
- (void)writeArray:(NSArray *)value;
- (void)writeECMAArray:(NSDictionary *)value;
- (void)writeASObject:(ASObject *)obj;
- (void)writeNumber:(NSNumber *)value;
- (void)writeDate:(NSDate *)value;

@end


@interface AMF3MutableByteArray : AMFByteArray
{
	NSMutableArray *m_stringTable;
	NSMutableArray *m_objectTable;
	NSMutableArray *m_traitsTable;
}

- (uint32_t)readUInt29;
- (void)writeUInt29:(uint32_t)value;
- (void)writeArray:(NSArray *)value;
- (void)writeString:(NSString *)value omitType:(BOOL)omitType;
- (void)writeDictionary:(NSDictionary *)value;
- (void)writeDate:(NSDate *)value;
- (void)writeNumber:(NSNumber *)value;
- (void)writeASObject:(ASObject *)value;

@end