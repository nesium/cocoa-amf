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

- (id)initForReadingWithData:(NSData *)data encoding:(AMFVersion)encoding;

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