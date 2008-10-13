//
//  AMFStream.m
//  CocoaAMF
//
//  Created by Marc Bauer on 11.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "AMFInputStream.h"


@implementation AMFInputStream

- (id)initWithData:(NSData *)data
{
	if (self = [super init])
	{
		m_data = [data retain];
		m_offset = 0;
	}
	return self;
}

- (void)dealloc
{
	[m_data release];
	[super dealloc];
}

- (uint8_t)readUInt8
{
	uint8_t buffer = 0;
	[m_data getBytes:&buffer range:(NSRange){m_offset++, 1}];
	return buffer;
}

- (uint16_t)readUInt16
{
	uint8_t ch1 = [self readUInt8];
	uint8_t ch2 = [self readUInt8];
	return (ch1 << 8) + (ch2 << 0);
}

- (uint32_t)readUInt29
{
	uint32_t value;
	uint8_t ch = [self readUInt8] & 0xFF;
	
	if (ch < 128)
	{
		return ch;
	}
	
	value = (ch & 0x7F) << 7;
	ch = [self readUInt8] & 0xFF;
	if (ch < 128)
	{
		return value | ch;
	}
	
	value = (value | (ch & 0x7F)) << 7;
	ch = [self readUInt8] & 0xFF;
	if (ch < 128)
	{
		return value | ch;
	}
	
	value = (value | (ch & 0x7F)) << 8;
	ch = [self readUInt8] & 0xFF;
	return value | ch;
}

- (uint32_t)readUInt32
{
	uint8_t ch1 = [self readUInt8];
	uint8_t ch2 = [self readUInt8];
	uint8_t ch3 = [self readUInt8];
	uint8_t ch4 = [self readUInt8];
	return ((ch1 << 24) + (ch2 << 16) + (ch3 << 8) + (ch4 << 0));
}

- (double)readDouble
{
	uint8_t data[8];
	
	data[7] = [self readUInt8];
	data[6] = [self readUInt8];
	data[5] = [self readUInt8];
	data[4] = [self readUInt8];
	data[3] = [self readUInt8];
	data[2] = [self readUInt8];
	data[1] = [self readUInt8];
	data[0] = [self readUInt8];
	
	return *((double *)data);
}

- (BOOL)readBool
{
	uint8_t ch = [self readUInt8];
	return ch != 0;
}

- (NSString *)readUTF8:(uint32_t)length
{
	if (length == 0)
	{
		return [NSString string];
	}
	return [[[NSString alloc] initWithData:[self readDataWithLength:length] 
		encoding:NSUTF8StringEncoding] autorelease];
}

- (uint8_t *)copyDataWithLength:(uint32_t)length
{
	uint8_t *buffer = malloc(length * sizeof(uint8_t));
	[m_data getBytes:buffer range:(NSRange){m_offset, length}];
	m_offset += length;
	return buffer;
}

- (NSData *)readDataWithLength:(uint32_t)length
{
	NSData *data = [m_data subdataWithRange:(NSRange){m_offset, length}];
	m_offset += length;
	return data;
}

@end