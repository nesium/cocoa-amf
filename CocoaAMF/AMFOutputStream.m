//
//  AMFOutputStream.m
//  SimpleHTTPServer
//
//  Created by Marc Bauer on 12.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "AMFOutputStream.h"


@implementation AMFOutputStream

@synthesize data=m_data;


#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init
{
	if (self = [super init])
	{
		m_data = [[NSMutableData alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[m_data release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)writeUInt8:(uint8_t)value
{
	[m_data appendBytes:&value length:sizeof(uint8_t)];
}

- (void)writeUInt16:(uint16_t)value
{
	value = CFSwapInt16HostToBig(value);
	[m_data appendBytes:&value length:sizeof(uint16_t)];
}

- (void)writeUInt29:(uint32_t)value
{
	if (value < 0x80)
	{
		[self writeUInt8:value];
	}
	else if (value < 0x4000)
	{
		[self writeUInt8:((value >> 7) & 0x7F) | 0x80];
		[self writeUInt8:(value & 0x7F)];
	}
	else if (value < 0x200000)
	{
		[self writeUInt8:((value >> 14) & 0x7F) | 0x80];
		[self writeUInt8:((value >> 7) & 0x7F) | 0x80];
		[self writeUInt8:(value & 0x7F)];
	}
	else
	{
		[self writeUInt8:((value >> 22) & 0x7F) | 0x80];
		[self writeUInt8:((value >> 15) & 0x7F) | 0x80];
		[self writeUInt8:((value >> 8) & 0x7F) | 0x80];
		[self writeUInt8:(value & 0xFF)];
	}
}

- (void)writeUInt32:(uint32_t)value
{
	value = CFSwapInt32HostToBig(value);
	[m_data appendBytes:&value length:sizeof(uint32_t)];
}

- (void)writeDouble:(double)value
{
}

- (void)writeBool:(BOOL)value
{
}

- (void)writeData:(NSData *)value
{
	[m_data appendData:value];
}

@end