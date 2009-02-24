//
//  AMFMutableByteArray.m
//  CocoaAMF
//
//  Created by Marc Bauer on 13.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "AMFArchiver.h"

@class AMF3TraitsInfo;

@interface AMFArchiver (Private)
- (void)_ensureLength:(unsigned)length;
- (void)_appendBytes:(const void *)bytes length:(NSUInteger)length;

- (void)_encodeDate:(NSDate *)value;
- (void)_encodeArray:(NSArray *)value;
- (void)_encodeDictionary:(NSDictionary *)value;
- (void)_encodeNumber:(NSNumber *)value;
- (void)_encodeASObject:(ASObject *)value;
- (void)_encodeCustomObject:(id)value;
- (void)_encodeString:(NSString *)value omitType:(BOOL)omitType;
@end

@interface AMF0Archiver (Private)
@end

@interface AMF3Archiver (Private)
- (void)_encodeTraits:(AMF3TraitsInfo *)traits;
- (void)_encodeData:(NSData *)value;
@end


@implementation AMFArchiver

static NSMutableDictionary *g_registeredClasses = nil;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init
{
	if (self = [super init])
	{
		m_data = [[NSMutableData alloc] init];
		m_position = 0;
		m_bytes = [m_data mutableBytes];
		m_objectTable = [[NSMutableArray alloc] init];
		m_currentSerializedObject = nil;
		m_registeredClasses = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (id)initForWritingWithMutableData:(NSMutableData *)data encoding:(AMFVersion)encoding
{
	NSZone *temp = [self zone];  // Must not call methods after release
	[self release];              // Placeholder no longer needed
	return (encoding == kAMF0Version)
		? [[AMF0Archiver allocWithZone:temp] initForWritingWithMutableData:data]
		: [[AMF3Archiver allocWithZone:temp] initForWritingWithMutableData:data];
}

- (id)initForWritingWithMutableData:(NSMutableData *)data
{
	if (self = [self init])
	{
		[data retain];
		[m_data release];
		m_data = data;
	}
	return self;
}

+ (NSData *)archivedDataWithRootObject:(id)rootObject encoding:(AMFVersion)encoding
{
	AMFArchiver *archiver = [[[AMFArchiver alloc] initForWritingWithMutableData:[NSMutableData data] 
		encoding:encoding] autorelease];
	[archiver encodeRootObject:rootObject];
	return [archiver data];
}

+ (BOOL)archiveRootObject:(id)rootObject encoding:(AMFVersion)encoding toFile:(NSString *)path;
{
   NSData *data = [self archivedDataWithRootObject:rootObject encoding:encoding];
   return [data writeToFile:path atomically:YES];
}

- (void)dealloc
{
	[m_objectTable release];
	[m_data release];
	[m_registeredClasses release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (NSData *)data
{
   return [[m_data copy] autorelease];
}

- (NSMutableData *)archiverData
{
   return m_data;
}

- (void)encodeRootObject:(id)rootObject
{
	[self encodeObject:rootObject];
}

- (void)setClassName:(NSString *)codedName forClass:(Class)cls
{
	[m_registeredClasses setObject:codedName forKey:cls];
}

+ (void)setClassName:(NSString *)codedName forClass:(Class)cls
{
	if (!g_registeredClasses) g_registeredClasses = [[NSMutableDictionary alloc] init];
	[g_registeredClasses setObject:codedName forKey:cls];
}

- (NSString *)classNameForClass:(Class)cls
{
	return [m_registeredClasses objectForKey:cls];
}

+ (NSString *)classNameForClass:(Class)cls
{
	return [g_registeredClasses objectForKey:cls];
}

- (void)encodeBool:(BOOL)value forKey:(NSString *)key
{
	[m_currentSerializedObject setValue:[NSNumber numberWithBool:value] forKey:key];
}

- (void)encodeDouble:(double)value forKey:(NSString *)key
{
	[m_currentSerializedObject setValue:[NSNumber numberWithDouble:value] forKey:key];
}

- (void)encodeFloat:(float)value forKey:(NSString *)key
{
	[m_currentSerializedObject setValue:[NSNumber numberWithFloat:value] forKey:key];
}

- (void)encodeInt32:(int32_t)value forKey:(NSString *)key
{
	[m_currentSerializedObject setValue:[NSNumber numberWithInt:value] forKey:key];
}

- (void)encodeInt64:(int64_t)value forKey:(NSString *)key
{
	[m_currentSerializedObject setValue:[NSNumber numberWithInteger:value] forKey:key];
}

- (void)encodeInt:(int)value forKey:(NSString *)key
{
	[m_currentSerializedObject setValue:[NSNumber numberWithInt:value] forKey:key];
}

- (void)encodeObject:(id)value forKey:(NSString *)key
{
	[m_currentSerializedObject setValue:value forKey:key];
}

- (void)encodeValueOfObjCType:(const char *)valueType at:(const void *)address
{
}

- (void)encodeBool:(BOOL)value
{
	[self encodeUnsignedChar:(value ? 1 : 0)];
}

- (void)encodeChar:(int8_t)value
{
	m_bytes[m_position++] = value;
}

- (void)encodeDataObject:(NSData *)value
{
	[m_data appendData:value];
	m_bytes = [m_data mutableBytes];
	m_position = [m_data length];
}

- (void)encodeDouble:(double)value
{
	uint8_t *ptr = (void *)&value;
	[self _ensureLength:8];
	m_bytes[m_position++] = ptr[7];
	m_bytes[m_position++] = ptr[6];
	m_bytes[m_position++] = ptr[5];
	m_bytes[m_position++] = ptr[4];
	m_bytes[m_position++] = ptr[3];
	m_bytes[m_position++] = ptr[2];
	m_bytes[m_position++] = ptr[1];
	m_bytes[m_position++] = ptr[0];	
}

- (void)encodeFloat:(float)value
{
	uint8_t *ptr = (void *)&value;
	[self _ensureLength:4];
	m_bytes[m_position++] = ptr[3];
	m_bytes[m_position++] = ptr[2];
	m_bytes[m_position++] = ptr[1];
	m_bytes[m_position++] = ptr[0];
}

- (void)encodeInt:(int32_t)value
{
	value = CFSwapInt32HostToBig(value);
	[self _appendBytes:&value length:sizeof(int32_t)];
}

- (void)encodeMultiByteString:(NSString *)value encoding:(NSStringEncoding)encoding
{
	[self encodeDataObject:[value dataUsingEncoding:encoding]];
}

- (void)encodeObject:(NSObject *)value
{
	if ([value isKindOfClass:[NSString class]])
	{
		[self _encodeString:(NSString *)value omitType:NO];
	}
	else if ([value isKindOfClass:[NSNumber class]])
	{
		[self _encodeNumber:(NSNumber *)value];
	}
	else if ([value isKindOfClass:[NSDate date]])
	{
		[self _encodeDate:(NSDate *)value];
	}
	else if ([value isKindOfClass:[NSArray class]])
	{
		[self _encodeArray:(NSArray *)value];
	}
	else if ([value isKindOfClass:[NSDictionary class]])
	{
		[self _encodeDictionary:(NSDictionary *)value];
	}
	else if ([value isKindOfClass:[ASObject class]])
	{
		[self _encodeASObject:(ASObject *)value];
	}
	else
	{
		[self _encodeCustomObject:value];
	}
}

- (void)encodeShort:(int16_t)value
{
	value = CFSwapInt16HostToBig(value);
	[self _appendBytes:&value length:sizeof(int16_t)];
}

- (void)encodeUnsignedInt:(uint32_t)value
{
	value = CFSwapInt32HostToBig(value);
	[self _appendBytes:&value length:sizeof(uint32_t)];
}

- (void)encodeUTF:(NSString *)value
{
	if (value == nil)
	{
		[self encodeUnsignedShort:0];
		return;
	}
	NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
	[self encodeUnsignedShort:[data length]];
	[self encodeDataObject:data];
}

- (void)encodeUTFBytes:(NSString *)value
{
	if (value == nil)
	{
		return;
	}
	[self encodeDataObject:[value dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)encodeUnsignedChar:(uint8_t)value
{
	[self _ensureLength:1];
	m_bytes[m_position++] = value;
}

- (void)encodeUnsignedShort:(uint16_t)value
{
	[self _ensureLength:2];
	m_bytes[m_position++] = (value >> 8) & 0xFF;
	m_bytes[m_position++] = value & 0xFF;
}

- (void)encodeUnsignedInt29:(uint32_t)value
{
	if (value < 0x80)
	{
		[self _ensureLength:1];
		m_bytes[m_position++] = value;
	}
	else if (value < 0x4000)
	{
		[self _ensureLength:2];
		m_bytes[m_position++] = ((value >> 7) & 0x7F) | 0x80;
		m_bytes[m_position++] = (value & 0x7F);
	}
	else if (value < 0x200000)
	{
		[self _ensureLength:3];
		m_bytes[m_position++] = ((value >> 14) & 0x7F) | 0x80;
		m_bytes[m_position++] = ((value >> 7) & 0x7F) | 0x80;
		m_bytes[m_position++] = (value & 0x7F);
	}
	else
	{
		[self _ensureLength:4];
		m_bytes[m_position++] = ((value >> 22) & 0x7F) | 0x80;
		m_bytes[m_position++] = ((value >> 15) & 0x7F) | 0x80;
		m_bytes[m_position++] = ((value >> 8) & 0x7F) | 0x80;
		m_bytes[m_position++] = (value & 0xFF);
	}
}



#pragma mark -
#pragma mark Private methods

- (void)_ensureLength:(unsigned)length
{
	[m_data setLength:[m_data length] + length];
	m_bytes = [m_data mutableBytes];
}

- (void)_encodeCustomObject:(id)value
{
	ASObject *obj = m_currentSerializedObject = [[[ASObject alloc] init] autorelease];
	obj.type = [[self class] classNameForClass:[value class]];
	if (!obj.type) obj.type = [self classNameForClass:[value class]];
	if (!obj.type) obj.type = [value className];
	[value encodeWithCoder:self];
	[self _encodeASObject:obj];
}

- (void)_appendBytes:(const void*)bytes length:(NSUInteger)length
{
	[self _ensureLength:length];
	uint8_t *chars = (uint8_t *)bytes;
	for (NSUInteger i = 0; i < length; i++)
		m_bytes[m_position++] = chars[i];
}
@end



@implementation AMF0Archiver

#pragma mark -
#pragma mark Public methods

- (void)encodeUTF:(NSString *)value
{
	if (value == nil)
	{
		[self encodeUnsignedShort:0];
		return;
	}
	NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
	if ([data length] > 0xFFFF)
	{
		[self encodeUnsignedInt:[data length]];
	}
	else
	{
		[self encodeUnsignedShort:[data length]];
	}
	[self encodeDataObject:data];
}



#pragma mark -
#pragma mark Private methods

- (void)_encodeString:(NSString *)value omitType:(BOOL)omitType
{
	NSData *stringData = [value dataUsingEncoding:NSUTF8StringEncoding];
	if ([stringData length] > 0xFFFF)
	{
		omitType ?: [self encodeUnsignedChar:kAMF0LongStringType];
		[self encodeUnsignedInt:[stringData length]];
	}
	else
	{
		omitType ?: [self encodeUnsignedChar:kAMF0StringType];
		[self encodeUnsignedShort:[stringData length]];
	}
	[self encodeDataObject:stringData];
}

- (void)_encodeArray:(NSArray *)value
{
	if ([m_objectTable containsObject:value])
	{
		[self encodeUnsignedChar:kAMF0ReferenceType];
		[self encodeUnsignedShort:[m_objectTable indexOfObject:value]];
		return;
	}
	[m_objectTable addObject:value];
	[self encodeUnsignedChar:kAMF0StrictArrayType];
	[self encodeUnsignedInt:[value count]];
	for (id obj in value)
	{
		[self encodeObject:obj];
	}
}

- (void)_encodeDictionary:(NSDictionary *)value
{
	if ([m_objectTable containsObject:value])
	{
		[self encodeUnsignedChar:kAMF0ReferenceType];
		[self encodeUnsignedShort:[m_objectTable indexOfObject:value]];
		return;
	}
	[m_objectTable addObject:value];
	
	// empty ecma arrays won't get parsed properly. seems like a bug to me
	if ([value count] == 0)
	{
		// so we write a generic empty object
		[self encodeUnsignedChar:kAMF0ObjectType];
		[self encodeUnsignedShort:0];
		[self encodeUnsignedChar:kAMF0ObjectEndType];
		return;
	}
	[self encodeUnsignedChar:kAMF0ECMAArrayType];
	//[self encodeUnsignedInt:[value count]];
	// PyAMF does always write 0 instead of length
	// @TODO look how flash handles this
	[self encodeUnsignedInt:0];
	for (NSString *key in value)
	{
		[self _encodeString:key omitType:YES];
		[self encodeObject:[value objectForKey:key]];
	}
	[self encodeUnsignedShort:0];
	[self encodeUnsignedChar:kAMF0ObjectEndType];
}

- (void)_encodeASObject:(ASObject *)value
{
	if ([m_objectTable containsObject:value])
	{
		[self encodeUnsignedChar:kAMF0ReferenceType];
		[self encodeUnsignedShort:[m_objectTable indexOfObject:value]];
		return;
	}
	[m_objectTable addObject:value];
	if (value.type == nil)
	{
		[self encodeUnsignedChar:kAMF0ObjectType];
		//[self encodeUnsignedShort:0];
	}
	else
	{
		[self encodeUnsignedChar:kAMF0TypedObjectType];
		[self _encodeString:value.type omitType:YES];
	}
	for (NSString *key in value.properties)
	{
		[self _encodeString:key omitType:YES];
		[self encodeObject:[value valueForKey:key]];
	}
	[self encodeUnsignedShort:0];
	[self encodeUnsignedChar:kAMF0ObjectEndType];
}

- (void)_encodeNumber:(NSNumber *)value
{
	if ([[value className] isEqualToString:@"NSCFBoolean"])
	{
		[self encodeUnsignedChar:kAMF0BooleanType];
		[self encodeBool:[value boolValue]];
		return;
	}
	[self encodeUnsignedChar:kAMF0NumberType];
	[self encodeDouble:[value doubleValue]];
}

- (void)writeDate:(NSDate *)value
{
	[self encodeUnsignedChar:kAMF0DateType];
	[self encodeDouble:([value timeIntervalSince1970] * 1000)];
	[self encodeUnsignedShort:([[NSTimeZone localTimeZone] secondsFromGMT] / 60)];
}

@end



@implementation AMF3Archiver

- (id)init
{
	if (self = [super init])
	{
		m_stringTable = [[NSMutableArray alloc] init];
		m_traitsTable = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[m_stringTable release];
	[m_traitsTable release];
	[super dealloc];
}

#pragma mark -
#pragma mark Public methods

- (void)encodeUTF:(NSString *)value
{
	if (value == nil)
	{
		[self encodeUnsignedInt29:((0 << 1) | 1)];
		return;
	}
	NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
	[self encodeUnsignedInt29:[data length]];
	[self encodeDataObject:data];
}

- (void)encodeBool:(BOOL)value
{
	[self encodeUnsignedChar:(value ? kAMF3TrueType : kAMF3FalseType)];
}



#pragma mark -
#pragma mark Private methods

- (void)_encodeCustomObject:(id)value
{
	if ([value isKindOfClass:[NSData class]])
		[self _encodeData:(NSData *)value];
	else
		[super _encodeCustomObject:value];
}

- (void)_encodeArray:(NSArray *)value
{
	[self encodeUnsignedChar:kAMF3ArrayType];
	if ([m_objectTable containsObject:value])
	{
		[self encodeUnsignedInt29:([m_objectTable indexOfObject:value] << 1)];
		return;
	}
	[m_objectTable addObject:value];
	[self encodeUnsignedInt29:(([value count] << 1) | 1)];
	[self encodeUnsignedChar:((0 << 1) | 1)];
	for (NSObject *obj in value)
	{
		[self encodeObject:obj];
	}
}

- (void)_encodeString:(NSString *)value omitType:(BOOL)omitType
{
	if (!omitType)
	{
		[self encodeUnsignedChar:kAMF3StringType];
	}
	if (value == nil || [value length] == 0)
	{
		[self encodeUnsignedChar:((0 << 1) | 1)];
		return;
	}
	if ([m_stringTable containsObject:value])
	{
		[self encodeUnsignedInt29:([m_stringTable indexOfObject:value] << 1)];
		return;
	}
	[m_stringTable addObject:value];
	NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
	[self encodeUnsignedInt29:(([data length] << 1) | 1)];
	[self encodeDataObject:data];
}

- (void)_encodeDictionary:(NSDictionary *)value
{
	[self _encodeASObject:[ASObject asObjectWithDictionary:value]];
}

- (void)_encodeDate:(NSDate *)value
{
	[self encodeUnsignedChar:kAMF3DateType];
	if ([m_objectTable containsObject:value])
	{
		[self encodeUnsignedInt29:([m_objectTable indexOfObject:value] << 1)];
		return;
	}
	[m_objectTable addObject:value];
	[self encodeUnsignedInt29:((0 << 1) | 1)];
	[self encodeDouble:([value timeIntervalSince1970] * 1000)];
}

- (void)_encodeData:(NSData *)value
{
	if ([m_objectTable containsObject:value])
	{
		[self encodeUnsignedInt29:([m_objectTable indexOfObject:value] << 1)];
		return;
	}
	[m_objectTable addObject:value];
	[self encodeUnsignedChar:kAMF3ByteArrayType];
	[self encodeUnsignedInt29:(([value length] << 1) | 1)];
	[self encodeDataObject:value];
}

- (void)_encodeNumber:(NSNumber *)value
{
	if ([[value className] isEqualToString:@"NSCFBoolean"])
	{
		[self encodeUnsignedChar:([value boolValue] ? kAMF3TrueType : kAMF3FalseType)];
		return;
	}
	if (strcmp([value objCType], "f") == 0 || 
		strcmp([value objCType], "d") == 0)
	{
		[self encodeUnsignedChar:kAMF3DoubleType];
		[self encodeDouble:[value doubleValue]];
		return;
	}
	[self encodeUnsignedChar:kAMF3IntegerType];
	[self encodeUnsignedInt29:[value intValue]];
}

- (void)_encodeASObject:(ASObject *)value
{
	[self encodeUnsignedChar:kAMF3ObjectType];
	if ([m_objectTable containsObject:value])
	{
		[self encodeUnsignedInt29:([m_objectTable indexOfObject:value] << 1)];
		return;
	}
	[m_objectTable addObject:value];
	AMF3TraitsInfo *traits = [[[AMF3TraitsInfo alloc] init] autorelease];
	traits.externalizable = value.isExternalizable;
	traits.dynamic = (value.type == nil || [value.type length] == 0);
	traits.count = (traits.dynamic ? 0 : [value count]);
	traits.className = value.type;
	traits.properties = (traits.dynamic ? nil : (id)[value.properties allKeys]);
	[self _encodeTraits:traits];
	
	NSEnumerator *keyEnumerator = [value.properties keyEnumerator];
	NSString *key;
	
	while (key = [keyEnumerator nextObject])
	{
		if (traits.dynamic)
		{
			[self _encodeString:key omitType:YES];
		}
		[self encodeObject:[value.properties objectForKey:key]];
	}
	if (traits.dynamic)
	{
		[self encodeUnsignedInt29:((0 << 1) | 1)];
	}
}

- (void)_encodeTraits:(AMF3TraitsInfo *)traits
{
	if ([m_traitsTable containsObject:traits])
	{
		[self encodeUnsignedInt29:(([m_traitsTable indexOfObject:traits] << 2) | 1)];
		return;
	}
	[m_traitsTable addObject:traits];
	uint32_t infoBits = 3;
	if (traits.externalizable) infoBits |= 4;
	if (traits.dynamic) infoBits |= 8;
	infoBits |= (traits.count << 4);
	[self encodeUnsignedInt29:infoBits];
	[self _encodeString:traits.className omitType:YES];
	for (uint32_t i = 0; i < traits.count; i++)
	{
		[self _encodeString:[traits.properties objectAtIndex:i] omitType:YES];
	}
}

@end
