//
//  AMFStream.h
//  CocoaAMF
//
//  Created by Marc Bauer on 11.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AMFInputStream : NSObject
{
	uint32_t m_offset;
	NSData *m_data;
}

- (id)initWithData:(NSData *)data;

- (uint8_t)readUInt8;
- (uint16_t)readUInt16;
- (uint32_t)readUInt29;
- (uint32_t)readUInt32;
- (double)readDouble;
- (BOOL)readBool;
- (NSString *)readUTF8:(uint32_t)length;

- (uint8_t *)copyDataWithLength:(uint32_t)length;
- (NSData *)readDataWithLength:(uint32_t)length;

@end