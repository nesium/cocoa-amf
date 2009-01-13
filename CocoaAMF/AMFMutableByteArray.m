//
//  AMFMutableByteArray.m
//  CocoaAMF
//
//  Created by Marc Bauer on 13.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "AMFMutableByteArray.h"

@interface AMF3ByteArray (Private)
- (void)writeTraits:(AMF3TraitsInfo *)traits;
@end


@implementation AMFMutableByteArray

#pragma mark -
#pragma mark Public methods

- (void)writeBoolean:(BOOL)value
{
	[self writeUnsignedByte:(value ? 1 : 0)];
}

- (void)writeByte:(int8_t)value
{
	[m_data appendBytes:&value length:sizeof(int8_t)];
}

- (void)writeBytes:(NSData *)value
{
	[m_data appendData:value];
}

- (void)writeDouble:(double)value
{
	uint8_t *ptr = (void *)&value;
	[self writeUnsignedByte:ptr[7]];
	[self writeUnsignedByte:ptr[6]];
	[self writeUnsignedByte:ptr[5]];
	[self writeUnsignedByte:ptr[4]];
	[self writeUnsignedByte:ptr[3]];
	[self writeUnsignedByte:ptr[2]];
	[self writeUnsignedByte:ptr[1]];
	[self writeUnsignedByte:ptr[0]];
}

- (void)writeFloat:(float)value
{
	uint8_t *ptr = (void *)&value;
	[self writeUnsignedByte:ptr[3]];
	[self writeUnsignedByte:ptr[2]];
	[self writeUnsignedByte:ptr[1]];
	[self writeUnsignedByte:ptr[0]];
}

- (void)writeInt:(int32_t)value
{
	value = CFSwapInt32HostToBig(value);
	[m_data appendBytes:&value length:sizeof(int32_t)];
}

- (void)writeMultiByte:(NSString *)value encoding:(NSStringEncoding)encoding
{
	[m_data appendData:[value dataUsingEncoding:encoding]];
}

- (void)writeObject:(NSObject *)value
{
}

- (void)writeShort:(int16_t)value
{
	value = CFSwapInt16HostToBig(value);
	[m_data appendBytes:&value length:sizeof(int16_t)];
}

- (void)writeUnsignedInt:(uint32_t)value
{
	value = CFSwapInt32HostToBig(value);
	[m_data appendBytes:&value length:sizeof(uint32_t)];
}

- (void)writeUTF:(NSString *)value
{
	if (value == nil)
	{
		[self writeUnsignedShort:0];
		return;
	}
	NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
	[self writeUnsignedShort:[data length]];
	[m_data appendData:data];
}

- (void)writeUTFBytes:(NSString *)value
{
	if (value == nil)
	{
		return;
	}
	[m_data appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
}



#pragma mark -
#pragma mark Protected methods

- (void)writeUnsignedByte:(uint8_t)value
{
	[m_data appendBytes:&value length:sizeof(uint8_t)];
}

- (void)writeUnsignedShort:(uint16_t)value
{
	value = CFSwapInt16HostToBig(value);
	[m_data appendBytes:&value length:sizeof(uint16_t)];
}

@end



@implementation AMF0MutableByteArray

#pragma mark -
#pragma mark Public methods

- (void)writeObject:(NSObject *)value
{
	AMF0KeyedArchiver *archiver = [[AMF0KeyedArchiver alloc] initForWritingWithByteArray:self];
	[archiver encodeRootObject:value];
	[archiver finishEncoding];
	[archiver release];
}

- (void)writeUTF:(NSString *)value
{
	if (value == nil)
	{
		[self writeUnsignedShort:0];
		return;
	}

	NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
	if ([data length] > 0xFFFF)
	{
		[self writeUnsignedInt:[data length]];
	}
	else
	{
		[self writeUnsignedShort:[data length]];
	}
	[m_data appendData:data];
}



#pragma mark -
#pragma mark Private methods

- (void)writeString:(NSString *)value omitType:(BOOL)omitType
{
	NSData *stringData = [value dataUsingEncoding:NSUTF8StringEncoding];
	
	if ([stringData length] > 0xFFFF)
	{
		omitType ?: [self writeUnsignedByte:kAMF0LongStringType];
		[self writeUnsignedInt:[stringData length]];
	}
	else
	{
		omitType ?: [self writeUnsignedByte:kAMF0StringType];
		[self writeUnsignedShort:[stringData length]];
	}
	[self writeBytes:stringData];
}

- (void)writeArray:(NSArray *)value
{
	if ([m_objectTable containsObject:value])
	{
		[self writeUnsignedByte:kAMF0ReferenceType];
		[self writeUnsignedShort:[m_objectTable indexOfObject:value]];
		return;
	}
	[m_objectTable addObject:value];
	[self writeUnsignedByte:kAMF0StrictArrayType];
	[self writeUnsignedInt:[value count]];
	for (id obj in value)
	{
		[self writeObject:obj];
	}
}

- (void)writeECMAArray:(NSDictionary *)value
{
	if ([m_objectTable containsObject:value])
	{
		[self writeUnsignedByte:kAMF0ReferenceType];
		[self writeUnsignedShort:[m_objectTable indexOfObject:value]];
		return;
	}
	[m_objectTable addObject:value];
	
	// empty ecma arrays won't get parsed properly. seems like a bug to me
	if ([value count] == 0)
	{
		// so we write a generic empty object
		[self writeUnsignedByte:kAMF0ObjectType];
		[self writeUnsignedShort:0];
		[self writeUnsignedByte:kAMF0ObjectEndType];
		return;
	}
	
	[self writeUnsignedByte:kAMF0ECMAArrayType];
	[self writeUnsignedInt:[value count]];
	for (NSString *key in value)
	{
		[self writeString:key omitType:YES];
		[self writeObject:[value objectForKey:key]];
	}
	[self writeUnsignedShort:0];
	[self writeUnsignedByte:kAMF0ObjectEndType];
}

- (void)writeASObject:(ASObject *)obj
{
	if ([m_objectTable containsObject:obj])
	{
		[self writeUnsignedByte:kAMF0ReferenceType];
		[self writeUnsignedShort:[m_objectTable indexOfObject:obj]];
		return;
	}
	[m_objectTable addObject:obj];
	if (obj.type == nil)
	{
		[self writeUnsignedByte:kAMF0ObjectType];
		[self writeUnsignedShort:0];
	}
	else
	{
		[self writeUnsignedByte:kAMF0TypedObjectType];
		[self writeString:obj.type omitType:YES];
	}
	for (NSString *key in obj.properties)
	{
		[self writeString:key omitType:YES];
		[self writeObject:[obj valueForKey:key]];
	}
	[self writeUnsignedShort:0];
	[self writeUnsignedByte:kAMF0ObjectEndType];
}

- (void)writeNumber:(NSNumber *)value
{
	if ([[value className] isEqualToString:@"NSCFBoolean"])
	{
		[self writeUnsignedByte:kAMF0BooleanType];
		[self writeBoolean:[value boolValue]];
		return;
	}
	[self writeUnsignedByte:kAMF0NumberType];
	[self writeDouble:[value doubleValue]];
}

- (void)writeDate:(NSDate *)value
{
	[self writeUnsignedByte:kAMF0DateType];
	[self writeDouble:([value timeIntervalSince1970] * 1000)];
	[self writeUnsignedShort:([[NSTimeZone localTimeZone] secondsFromGMT] / 60)];
}

@end



@implementation AMF3MutableByteArray

#pragma mark -
#pragma mark Public methods

- (void)writeUInt29:(uint32_t)value
{
	if (value < 0x80)
	{
		[self writeUnsignedByte:value];
	}
	else if (value < 0x4000)
	{
		[self writeUnsignedByte:((value >> 7) & 0x7F) | 0x80];
		[self writeUnsignedByte:(value & 0x7F)];
	}
	else if (value < 0x200000)
	{
		[self writeUnsignedByte:((value >> 14) & 0x7F) | 0x80];
		[self writeUnsignedByte:((value >> 7) & 0x7F) | 0x80];
		[self writeUnsignedByte:(value & 0x7F)];
	}
	else
	{
		[self writeUnsignedByte:((value >> 22) & 0x7F) | 0x80];
		[self writeUnsignedByte:((value >> 15) & 0x7F) | 0x80];
		[self writeUnsignedByte:((value >> 8) & 0x7F) | 0x80];
		[self writeUnsignedByte:(value & 0xFF)];
	}
}

- (void)writeObject:(NSObject *)value
{
	AMF3KeyedArchiver *archiver = [[AMF3KeyedArchiver alloc] initForWritingWithByteArray:self];
	[archiver encodeRootObject:value];
	[archiver finishEncoding];
	[archiver release];
}

- (void)writeUTF:(NSString *)value
{
	if (value == nil)
	{
		[self writeUInt29:0];
		return;
	}
	NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
	[self writeUInt29:[data length]];
	[self writeBytes:data];
}

- (void)writeBoolean:(BOOL)value
{
	[self writeUnsignedByte:(value ? kAMF3TrueType : kAMF3FalseType)];
}



#pragma mark -
#pragma mark Private methods

- (void)writeArray:(NSArray *)value
{
	[self writeUnsignedByte:kAMF3ArrayType];
	if ([m_objectTable containsObject:value])
	{
		[self writeUInt29:([m_objectTable indexOfObject:value] << 1)];
		return;
	}
	[m_objectTable addObject:value];
	[self writeUInt29:(([value count] << 1) | 1)];
	[self writeUnsignedByte:((0 << 1) | 1)];
	for (NSObject *obj in value)
	{
		[self writeObject:obj];
	}
}

- (void)writeString:(NSString *)value omitType:(BOOL)omitType
{
	if (!omitType)
	{
		[self writeUnsignedByte:kAMF3StringType];
	}
	if (value == nil || [value length] == 0)
	{
		[self writeUnsignedByte:0];
		return;
	}
	if ([m_stringTable containsObject:value])
	{
		[self writeUInt29:([m_stringTable indexOfObject:value] << 1)];
		return;
	}
	[m_stringTable addObject:value];
	NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
	[self writeUInt29:(([data length] << 1) | 1)];
	[self writeBytes:data];
}

- (void)writeDictionary:(NSDictionary *)value
{
	[self writeUnsignedByte:kAMF3ArrayType];
	if ([m_objectTable containsObject:value])
	{
		[self writeUInt29:([m_objectTable indexOfObject:value] << 1)];
		return;
	}
	[m_objectTable addObject:value];
	[self writeUInt29:((0 << 1) | 1)];
	NSEnumerator *keyEnumerator = [value keyEnumerator];
	NSString *key;
	while (key = [keyEnumerator nextObject])
	{
		[self writeString:key omitType:YES];
		[self writeObject:[value objectForKey:key]];
	}
	[self writeUnsignedByte:((0 << 1) | 1)];
}

- (void)writeDate:(NSDate *)value
{
	[self writeUnsignedByte:kAMF3DateType];
	if ([m_objectTable containsObject:value])
	{
		[self writeUInt29:([m_objectTable indexOfObject:value] << 1)];
		return;
	}
	[m_objectTable addObject:value];
	[self writeUInt29:((0 << 1) | 1)];
	[self writeDouble:([value timeIntervalSince1970] * 1000)];
}

- (void)writeNumber:(NSNumber *)value
{
	if ([[value className] isEqualToString:@"NSCFBoolean"])
	{
		[self writeUnsignedByte:([value boolValue] ? kAMF3TrueType : kAMF3FalseType)];
		return;
	}
	if (strcmp([value objCType], "f") == 0 || 
		strcmp([value objCType], "d") == 0)
	{
		[self writeUnsignedByte:kAMF3DoubleType];
		[self writeDouble:[value doubleValue]];
		return;
	}
	[self writeUnsignedByte:kAMF3IntegerType];
	[self writeUInt29:[value intValue]];
}

- (void)writeASObject:(ASObject *)value
{
	[self writeUnsignedByte:kAMF3ObjectType];
	if ([m_objectTable containsObject:value])
	{
		[self writeUInt29:([m_objectTable indexOfObject:value] << 1)];
		return;
	}
	[m_objectTable addObject:value];
	AMF3TraitsInfo *traits = [[AMF3TraitsInfo alloc] init];
	traits.externalizable = NO; // @FIXME
	traits.dynamic = (value.type == nil || [value.type length] == 0);
	traits.count = (traits.dynamic ? 0 : [value count]);
	traits.className = value.type;
	traits.properties = (traits.dynamic ? nil : (id)[value.properties allKeys]);
	[self writeTraits:traits];
	
	NSEnumerator *keyEnumerator = [value.properties keyEnumerator];
	NSString *key;
	
	while (key = [keyEnumerator nextObject])
	{
		if (traits.dynamic)
		{
			[self writeString:key omitType:YES];
		}
		[self writeObject:[value.properties objectForKey:key]];
	}
	if (traits.dynamic)
	{
		[self writeUInt29:((0 << 1) | 1)];
	}
	[traits release];
}

- (void)writeTraits:(AMF3TraitsInfo *)traits
{
	if ([m_traitsTable containsObject:traits])
	{
		[self writeUInt29:(([m_traitsTable indexOfObject:traits] << 2) | 1)];
		return;
	}
	[m_traitsTable addObject:traits];
	uint32_t infoBits = 3;
	if (traits.externalizable) infoBits |= 4;
	if (traits.dynamic) infoBits |= 8;
	infoBits |= (traits.count << 4);
	[self writeUInt29:infoBits];
	[self writeString:traits.className omitType:YES];
	for (uint32_t i = 0; i < traits.count; i++)
	{
		[self writeString:[traits.properties objectAtIndex:i] omitType:YES];
	}
}

@end
