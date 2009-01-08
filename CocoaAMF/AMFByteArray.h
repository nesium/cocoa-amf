//
//  AMFByteArray.h
//  RSFGameServer
//
//  Created by Marc Bauer on 22.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMF.h"
#import "ASObject.h"


@interface AMFByteArray : NSObject 
{
	NSMutableData *m_data;
	AMFVersion m_objectEncoding;
	uint32_t m_position;
}

@property (nonatomic, readonly) AMFVersion objectEncoding;
@property (nonatomic, readonly) uint32_t length;
@property (nonatomic, readonly) uint32_t bytesAvailable;
@property (nonatomic, assign) uint32_t position;
@property (nonatomic, readonly) NSData *data;

- (id)initWithData:(NSData *)data encoding:(AMFVersion)encoding;

//- (void)compress;
- (BOOL)readBoolean;
- (int8_t)readByte;
- (NSData *)readBytes:(uint32_t)length;
- (double)readDouble;
- (float)readFloat;
- (int32_t)readInt;
- (NSString *)readMultiByte:(uint32_t)length encoding:(NSStringEncoding)encoding;
- (NSObject *)readObject;
- (int16_t)readShort;
- (uint8_t)readUnsignedByte;
- (uint32_t)readUnsignedInt;
- (uint16_t)readUnsignedShort;
- (NSString *)readUTF;
- (NSString *)readUTFBytes:(uint32_t)length;
// - (void)uncompress;

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


@interface AMF0ByteArray : AMFByteArray
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


@interface AMF3ByteArray : AMFByteArray
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