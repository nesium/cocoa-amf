//
//  AMFByteArray.m
//  RSFGameServer
//
//  Created by Marc Bauer on 22.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "AMFByteArray.h"
#import "AMF0KeyedArchiver.h"
#import "AMF3KeyedArchiver.h"


@interface AMFByteArray (Protected)
- (void)_ensureLength:(unsigned)length;
- (void)_cannotDecodeType:(const char *)type;
@end



#pragma mark -



@interface AMF0ByteArray (Private)
- (NSObject *)readObjectWithType:(AMF0Type)type;
- (NSArray *)readArray;
- (NSObject *)readTypedObject;
- (NSObject *)readASObject:(NSString *)className;
- (NSString *)readLongString;
- (NSString *)readXML;
- (NSDate *)readDate;
- (NSDictionary *)readECMAArray;
- (NSObject *)readReference;
@end



#pragma mark -



@interface AMF3ByteArray (Private)
- (NSObject *)readObjectWithType:(AMF0Type)type;
- (NSObject *)readASObject;
- (NSObject *)readArray;
- (AMF3TraitsInfo *)readTraits:(uint32_t)infoBits;
- (void)readExternalizableWithClassName:(NSString *)aClassName object:(NSObject *)object;
- (NSString *)readXML;
- (NSData *)readByteArray;
- (NSDate *)readDate;
@end



#pragma mark -




@implementation AMFByteArray

@synthesize objectEncoding=m_objectEncoding, data=m_data;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initForReadingWithData:(NSData *)data encoding:(AMFVersion)encoding
{
	NSZone *temp = [self zone];  // Must not call methods after release
	[self release];              // Placeholder no longer needed
	return (encoding == kAMF0Version)
		? [[AMF0ByteArray allocWithZone:temp] initForReadingWithData:data]
		: [[AMF3ByteArray allocWithZone:temp] initForReadingWithData:data];
}

- (id)initForReadingWithData:(NSData *)data
{
	if (self = [super init])
	{
		m_data = [data retain];
		m_bytes = [data bytes];
		m_position = 0;
	}
	return self;
}

+ (id)unarchiveObjectWithData:(NSData *)data encoding:(AMFVersion)encoding
{
	if (data == nil)
	{
		[NSException raise:@"AMFInvalidArchiveOperationException" format:@"Invalid data"];
	}
	AMFByteArray *byteArray = [[AMFByteArray alloc] initWithData:data encoding:encoding];
	id object = [[byteArray _decodeObject] retain];
	[byteArray release];
	return [object autorelease];
}

+ (id)unarchiveObjectWithFile:(NSString *)path encoding:(AMFVersion)encoding
{
	NSData *data = [NSData dataWithContentsOfFile:path];
	return [[self class] unarchiveObjectWithData:data encoding:encoding];
}

- (void)dealloc
{
	[m_data release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (BOOL)containsValueForKey:(NSString *)key
{
	return NO;
}

- (BOOL)decodeBoolForKey:(NSString *)key
{
	return NO;
}

- (const uint8_t *)decodeBytesForKey:(NSString *)key returnedLength:(NSUInteger *)lengthp
{
	return NULL;
}

- (double)decodeDoubleForKey:(NSString *)key
{
	return 0.0;
}

- (float)decodeFloatForKey:(NSString *)key
{
	// If the archived value was encoded as double precision, the type is coerced, 
	// loosing precision. If the archived value is too large for single precision, 
	// the method raises an NSRangeException.
	return 0.0f;
}

- (int32_t)decodeInt32ForKey:(NSString *)key
{
	return 0;
}

- (int64_t)decodeInt64ForKey:(NSString *)key
{
	return 0;
}

- (int)decodeIntForKey:(NSString *)key
{
	return 0;
}

- (id)decodeObjectForKey:(NSString *)key
{
	return nil;
}

- (void)finishDecoding
{
}

- (Class)classForClassName:(NSString *)codedName
{
	return NULL;
}

- (void)setClass:(Class)cls forClassName:(NSString *)codedName
{
}

- (void)decodeValueOfObjCType:(const char *)valueType at:(void *)data
{
	switch (*valueType)
	{
		case 'c':
		{
			int8_t *value = data;
			*value = [self _decodeChar];
		}
		break;
		case 'C':
		{
			uint8_t *value = data;
			*value = [self _decodeUnsignedChar];
		}
		break;
		case 'i':
		{
			int32_t *value = data;
			*value = [self _decodeInt];
		}
		break;
		case 'I':
		{
			uint32_t *value = data;
			*value = [self _decodeUnsignedInt];
		}
		break;
		case 's':
		{
			int16_t *value = data;
			*value = [self _decodeShort];
		}
		break;
		case 'S':
		{
			uint16_t *value = data;
			*value = [self _decodeUnsignedShort];
		}
		break;
		case 'f':
		{
			float *value = data;
			*value = [self _decodeFloat];
		}
		break;
		case 'd':
		{
			double *value = data;
			*value = [self _decodeDouble];
		}
		break;
		case 'B':
		{
			uint8_t *value = data;
			*value = [self _decodeUnsignedChar];
		}
		break;
		case '*':
		{
			const char **cString = data;
			NSString *string = [self _decodeUTF];
			*cString = NSZoneMalloc(NSDefaultMallocZone(), 
				[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1);
			*cString = [string cStringUsingEncoding:NSUTF8StringEncoding];
		}
		break;
		case '@':
		{
			id *obj = data;
			*obj = [self _decodeObject];
		}
		break;
		default:
			[self _cannotDecodeType:valueType];
	}
}

- (BOOL)readBoolean
{
	return ([self _decodeUnsignedChar] != 0);
}

//- (void)decodeObject
//{
//	unsigned ref = [self _extractWordFour];
//	id result;
//	
//	if (ref == 0)
//		return nil;
//	else if ((result = NSMapGet(_objects, (void *)ref)) != nil)
//		[result retain];
//	else
//	{
//		Class class = [self _extractClass];
//	}
//
//    result=[class allocWithZone:NULL];
//    NSMapInsert(_objects,(void *)ref,result);
//    result=[result initWithCoder:self];
//    result=[result awakeAfterUsingCoder:self];
//
//    NSMapInsert(_objects,(void *)ref,result);
//
//    [_allObjects addObject:result];
//   }
//
//   return result;
//}





- (uint32_t)bytesAvailable
{
	return ([m_data length] - m_position);
}

//- (void)compress;

- (int8_t)_decodeChar
{
	[self _ensureLength:1];
	int8_t byte;
	[m_data getBytes:&byte range:(NSRange){m_position++, 1}];
	return byte;
}

- (NSData *)readBytes:(uint32_t)length
{
	[self _ensureLength:length];
	NSData *subdata = [m_data subdataWithRange:(NSRange){m_position, length}];
	m_position += length;
	return subdata;
}

- (double)_decodeDouble
{
	[self _ensureLength:8];
	uint8_t data[8];
	data[7] = m_bytes[m_position++];
	data[6] = m_bytes[m_position++];
	data[5] = m_bytes[m_position++];
	data[4] = m_bytes[m_position++];
	data[3] = m_bytes[m_position++];
	data[2] = m_bytes[m_position++];
	data[1] = m_bytes[m_position++];
	data[0] = m_bytes[m_position++];
	return *((double *)data);
}

- (float)_decodeFloat
{
	[self _ensureLength:4];
	uint8_t data[4];
	data[3] = m_bytes[m_position++];
	data[2] = m_bytes[m_position++];
	data[1] = m_bytes[m_position++];
	data[0] = m_bytes[m_position++];
	return *((float *)data);
}

- (int32_t)_decodeInt
{
	[self _ensureLength:4];
	uint8_t ch1 = [self _decodeChar];
	uint8_t ch2 = [self _decodeChar];
	uint8_t ch3 = [self _decodeChar];
	uint8_t ch4 = [self _decodeChar];
	return (ch1 << 24) + (ch2 << 16) + (ch3 << 8) + ch4;
}

- (NSString *)readMultiByte:(uint32_t)length encoding:(NSStringEncoding)encoding
{
	return [[[NSString alloc] initWithData:[self readBytes:length] encoding:encoding] autorelease];
}

- (NSObject *)_decodeObject
{
	return nil;
}

- (int16_t)_decodeShort
{
	[self _ensureLength:2];
	int8_t ch1 = [self _decodeChar];
	int8_t ch2 = [self _decodeChar];
	return (ch1 << 8) + ch2;
}

- (uint8_t)_decodeUnsignedChar
{
	[self _ensureLength:1];
	return m_bytes[m_position++];
}

- (uint32_t)_decodeUnsignedInt
{
	[self _ensureLength:4];
	uint8_t ch1 = m_bytes[m_position++];
	uint8_t ch2 = m_bytes[m_position++];
	uint8_t ch3 = m_bytes[m_position++];
	uint8_t ch4 = m_bytes[m_position++];
	return ((ch1 & 0xFF) << 24) | ((ch2 & 0xFF) << 16) | ((ch3 & 0xFF) << 8) | (ch4 & 0xFF);
}

- (uint16_t)_decodeUnsignedShort
{
	[self _ensureLength:2];
	int8_t ch1 = [self _decodeChar];
	int8_t ch2 = [self _decodeChar];
	return ((ch1 & 0xFF) << 8) | (ch2 & 0xFF);
}

- (NSString *)_decodeUTF
{
	return [self _decodeUTFBytes:[self _decodeUnsignedShort]];
}

- (NSString *)_decodeUTFBytes:(uint32_t)length
{
	if (length == 0)
	{
		return [NSString string];
	}
	[self _ensureLength:length];
	return [[[NSString alloc] initWithData:[self readBytes:length] 
		encoding:NSUTF8StringEncoding] autorelease];
}

// - (void)uncompress;


#pragma mark -
#pragma mark Private methods

- (void)_ensureLength:(unsigned)length
{
	if (m_position + length > [m_data length])
	{
		[NSException raise:@"NSUnarchiverBadArchiveException"
			format:@"%@ attempt to read beyond length", [self className]];
	}
}

- (void)_cannotDecodeType:(const char *)type
{
	[NSException raise:@"NSUnarchiverCannotDecodeException"
		format:@"%@ cannot decode type=%s", [self className], type];
}


@end



#pragma mark -



@implementation AMF0ByteArray

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initForReadingWithData:(NSData *)data
{
	if (self = [super initForReadingWithData:data])
	{
		m_objectTable = [[NSMutableArray alloc] init];
		m_objectEncoding = kAMF0Version;
		m_avmPlusByteArray = nil;
	}
	return self;
}

- (void)dealloc
{
	[m_objectTable release];
	[m_avmPlusByteArray release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (NSObject *)_decodeObject
{
	AMF0Type type = (AMF0Type)[self _decodeUnsignedChar];
	return [self readObjectWithType:type];
}



#pragma mark -
#pragma mark Private methods

- (NSObject *)readObjectWithType:(AMF0Type)type
{
	id value = nil;
	switch (type)
	{
		case kAMF0NumberType:
			value = [NSNumber numberWithDouble:[self _decodeDouble]];
			break;
			
		case kAMF0BooleanType:
			value = [NSNumber numberWithBool:[self readBoolean]];
			break;
			
		case kAMF0StringType:
			value = [self _decodeUTF];
			break;
			
		case kAMF0AVMPlusObjectType:
//			if (m_avmPlusByteArray == nil)
//			{
//				m_avmPlusByteArray = [[AMFByteArray alloc] initWithData:m_data 
//					encoding:kAMF3Version];
//			}
//			m_avmPlusByteArray.position = m_position;
//			value = [m_avmPlusByteArray readObject];
			break;
			
		case kAMF0StrictArrayType:
			value = [self readArray];
			break;
			
		case kAMF0TypedObjectType:
			value = [self readTypedObject];
			break;
			
		case kAMF0LongStringType:
			value = [self readLongString];
			break;
			
		case kAMF0ObjectType:
			value = [self readASObject:nil];
			break;
			
		case kAMF0XMLObjectType:
			value = [self readXML];
			break;
			
		case kAMF0NullType:
			value = [NSNull null];
			break;
			
		case kAMF0DateType:
			value = [self readDate];
			break;
			
		case kAMF0ECMAArrayType:
			value = [self readECMAArray];
			break;
			
		case kAMF0ReferenceType:
			value = [self readReference];
			break;
			
		case kAMF0UndefinedType:
			value = [NSNull null];
			break;
			
		case kAMF0UnsupportedType:
			NSLog(@"Unsupported type");
			break;
			
		case kAMF0ObjectEndType:
			NSLog(@"Unexpected object end");
			break;
			
		case kAMF0RecordsetType:
			NSLog(@"Unexpected recordset");
			break;
			
		default:
			NSLog(@"Unknown type");
	}
	return value;
}

- (NSArray *)readArray
{
	uint32_t size = [self _decodeUnsignedInt];
	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:size];
	for (uint32_t i = 0; i < size; i++)
	{
		NSObject *obj = [self _decodeObject];
		if (obj != nil)
		{
			[array addObject:obj];
		}
	}
	[m_objectTable addObject:array];
	[array release];
	return array;
}

- (NSObject *)readTypedObject
{
	NSString *className = [self _decodeUTF];
	return [self readASObject:className];
}

- (NSObject *)readASObject:(NSString *)className
{
	NSObject *object;
	if (className == nil || [className length] == 0)
	{
		object = [[ASObject alloc] init];
	}
	else if ([[className substringToIndex:1] isEqualToString:@">"])
	{
		object = [[ASObject alloc] init];
		[(ASObject *)object setType:className];
	}
	else
	{
		Class deserializedObjectClass = objc_getClass([className 
			cStringUsingEncoding:NSUTF8StringEncoding]);
		if (deserializedObjectClass == nil)
		{
			object = [[ASObject alloc] init];
			[(ASObject *)object setType:className];
		}
		else
		{
			object = [[deserializedObjectClass alloc] init];
		}
	}
	
	[m_objectTable addObject:object];
	[object release];
	
	NSString *propertyName = [self _decodeUTF];
	AMF0Type type = [self _decodeUnsignedChar];
	while (type != kAMF0ObjectEndType)
	{
		[object setValue:[self readObjectWithType:type] forKey:propertyName];
		propertyName = [self _decodeUTF];
		type = [self _decodeUnsignedChar];
	}
	
	return object;
}

- (NSString *)readLongString
{
	uint32_t length = [self _decodeUnsignedInt];
	if (length == 0)
	{
		return [NSString string];
	}
	return [self _decodeUTFBytes:length];
}

- (NSString *)readXML
{
	//@FIXME
	return [self readLongString];
}

- (NSDate *)readDate
{
	NSTimeInterval time = [self _decodeDouble];
	// timezone
	[self _decodeUnsignedShort];
	return [NSDate dateWithTimeIntervalSince1970:(time / 1000)];
}

- (NSDictionary *)readECMAArray
{
	uint32_t size = [self _decodeUnsignedInt];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:size];
	[m_objectTable addObject:dict];
	[dict release];
	
	NSString *propertyName = [self _decodeUTF];
	AMF0Type type = [self _decodeUnsignedChar];
	while (type != kAMF0ObjectEndType)
	{
		[dict setValue:[self readObjectWithType:type] forKey:propertyName];
		propertyName = [self _decodeUTF];
		type = [self _decodeUnsignedChar];
	}
	return dict;
}

- (NSObject *)readReference
{
	uint16_t index = [self _decodeUnsignedShort];
	if (index >= [m_objectTable count])
	{
		return nil;
	}
	return [m_objectTable objectAtIndex:index];
}

@end



#pragma mark -



@implementation AMF3ByteArray

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initForReadingWithData:(NSData *)data
{
	if (self = [super initForReadingWithData:data])
	{
		m_objectTable = [[NSMutableArray alloc] init];
		m_stringTable = [[NSMutableArray alloc] init];
		m_traitsTable = [[NSMutableArray alloc] init];
		m_objectEncoding = kAMF3Version;
	}
	return self;
}

- (void)dealloc
{
	[m_objectTable release];
	[m_stringTable release];
	[m_traitsTable release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (uint32_t)readUInt29
{
	uint32_t value;
	uint8_t ch = [self _decodeUnsignedChar] & 0xFF;
	
	if (ch < 128)
	{
		return ch;
	}
	
	value = (ch & 0x7F) << 7;
	ch = [self _decodeUnsignedChar] & 0xFF;
	if (ch < 128)
	{
		return value | ch;
	}
	
	value = (value | (ch & 0x7F)) << 7;
	ch = [self _decodeUnsignedChar] & 0xFF;
	if (ch < 128)
	{
		return value | ch;
	}
	
	value = (value | (ch & 0x7F)) << 8;
	ch = [self _decodeUnsignedChar] & 0xFF;
	return value | ch;
}

- (NSObject *)_decodeObject
{
	AMF3Type type = (AMF3Type)[self _decodeUnsignedChar];
	return [self readObjectWithType:type];
}

- (NSString *)_decodeUTF
{
	uint32_t ref = [self readUInt29];
	if ((ref & 1) == 0)
	{
		ref = (ref >> 1);
		if (ref < [m_stringTable count])
		{
			return (NSString *)[m_stringTable objectAtIndex:ref];
		}
		NSLog(@"String reference %d is out of bounds", ref);
		return [NSString string];
	}
	uint32_t length = ref >> 1;
	if (length == 0)
	{
		return [NSString string];
	}
	NSString *value = [self _decodeUTFBytes:length];
	[m_stringTable addObject:value];
	return value;
}



#pragma mark -
#pragma mark Private methods

- (NSObject *)readObjectWithType:(AMF0Type)type
{
	id value = nil;
	switch (type)
	{
		case kAMF3StringType:
			value = [self _decodeUTF];
			break;
		
		case kAMF3ObjectType:
			value = [self readASObject];
			break;
			
		case kAMF3ArrayType:
			value = [self readArray];
			break;
			
		case kAMF3FalseType:
			value = [NSNumber numberWithBool:NO];
			break;
			
		case kAMF3TrueType:
			value = [NSNumber numberWithBool:YES];
			break;
			
		case kAMF3IntegerType:
			value = [NSNumber numberWithInt:[self readUInt29]];
			break;
			
		case kAMF3DoubleType:
			value = [NSNumber numberWithDouble:[self _decodeDouble]];
			break;
			
		case kAMF3UndefinedType:
			return [NSNull null];
			break;
			
		case kAMF3NullType:
			return [NSNull null];
			break;
			
		case kAMF3XMLType:
		case kAMF3XMLDocType:
			value = [self readXML];
			break;
			
		case kAMF3DateType:
			value = [self readDate];
			break;
			
		case kAMF3ByteArrayType:
			value = [self readByteArray];
			break;
			
		default:
			NSLog(@"Can not decode unknown type");
			// throw exception here
			break;
	}
	return value;
}

- (NSObject *)readASObject
{
	uint32_t ref = [self readUInt29];
	if ((ref & 1) == 0)
	{
		ref = (ref >> 1);
		if (ref < [m_objectTable count])
		{
			return [m_objectTable objectAtIndex:ref];
		}
		NSLog(@"Object reference is out of bounds");
		return [[[ASObject alloc] init] autorelease];
	}
	
	AMF3TraitsInfo *traitsInfo = [self readTraits:ref];
	NSObject *object;
	if (traitsInfo.className == nil || [traitsInfo.className length] == 0)
	{
		object = [[ASObject alloc] init];
	}
	else if ([[traitsInfo.className substringToIndex:1] isEqualToString:@">"])
	{
		object = [[ASObject alloc] init];
		[(ASObject *)object setType:traitsInfo.className];
	}
	else
	{
		Class deserializedObjectClass = objc_getClass([traitsInfo.className 
			cStringUsingEncoding:NSUTF8StringEncoding]);
		if (deserializedObjectClass == nil)
		{
			object = [[ASObject alloc] init];
			[(ASObject *)object setType:traitsInfo.className];
		}
		else
		{
			object = [[deserializedObjectClass alloc] init];
		}
	}
	
	[m_objectTable addObject:object];
	[object release];
	
	if (traitsInfo.externalizable)
	{
		[self readExternalizableWithClassName:traitsInfo.className object:object];
		return object;
	}
	
	NSEnumerator *propertiesEnumerator = [traitsInfo.properties objectEnumerator];
	NSString *property;
	while (property = [propertiesEnumerator nextObject])
	{
		[object setValue:[self _decodeObject] forKey:property];
	}
	
	if (traitsInfo.dynamic)
	{
		property = [self _decodeUTF];
		while (property != nil && [property length] > 0)
		{
			[object setValue:[self _decodeObject] forKey:property];
			property = [self _decodeUTF];
		}
	}
	return object;
}

- (NSObject *)readArray
{
	uint32_t ref = [self readUInt29];
	
	if ((ref & 1) == 0)
	{
		ref = (ref >> 1);
		if (ref < [m_objectTable count])
		{
			return [m_objectTable objectAtIndex:ref];
		}
		NSLog(@"Array reference is out of bounds");
		return [NSArray array];
	}
	
	uint32_t length = (ref >> 1);
	NSObject *array = nil;
	for (;;)
	{
		NSString *name = [self _decodeUTF];
		if (name == nil || [name length] == 0) 
		{
			break;
		}
		
		if (array == nil)
		{
			array = [NSMutableDictionary dictionary];
		}
		[(NSMutableDictionary *)array setObject:[self _decodeObject] forKey:name];
	}
	
	if (array == nil)
	{
		array = [NSMutableArray array];
		for (uint32_t i = 0; i < length; i++)
		{
			[(NSMutableArray *)array addObject:[self _decodeObject]];
		}
	}
	else
	{
		for (uint32_t i = 0; i < length; i++)
		{
			[(NSMutableDictionary *)array setObject:[self _decodeObject] 
				forKey:[NSNumber numberWithInt:i]];
		}
	}
	[m_objectTable addObject:array];
	
	return array;
}

- (AMF3TraitsInfo *)readTraits:(uint32_t)infoBits
{
	if ((infoBits & 3) == 1)
	{
		infoBits = (infoBits >> 2);
		if (infoBits < [m_traitsTable count])
		{
			return [m_traitsTable objectAtIndex:infoBits];
		}
		NSLog(@"Traits reference is out of bounds");
		return [[[AMF3TraitsInfo alloc] init] autorelease];
	}
	BOOL externalizable = (infoBits & 4) == 4;
	BOOL dynamic = (infoBits & 8) == 8;
	NSUInteger count = infoBits >> 4;
	NSString *className = [self _decodeUTF];
	
	AMF3TraitsInfo *info = [[AMF3TraitsInfo alloc] init];
	info.className = className;
	info.dynamic = dynamic;
	info.externalizable = externalizable;
	info.count = count;
	while (count--)
	{
		[info addProperty:[self _decodeUTF]];
	}
	[m_traitsTable addObject:info];
	[info release];
	return info;
}

- (void)readExternalizableWithClassName:(NSString *)aClassName object:(NSObject *)object
{
	// @FIXME
	NSLog(@"Should read externalizable for class %@", aClassName);
}

- (NSString *)readXML
{
	// @FIXME
	return [self _decodeUTF];
}

- (NSData *)readByteArray
{
	uint32_t ref = [self readUInt29];
	if ((ref & 1) == 0)
	{
		ref = (ref >> 1);
		if (ref < [m_objectTable count])
		{
			return [m_objectTable objectAtIndex:ref];
		}
		NSLog(@"Object reference is out of bounds");
		return [NSData data];
	}
	uint32_t length = (ref >> 1);
	NSData *data = [self readBytes:length];
	return data;
}

- (NSDate *)readDate
{
	uint32_t ref = [self readUInt29];
	if ((ref & 1) == 0)
	{
		ref = (ref >> 1);
		if (ref < [m_objectTable count])
		{
			return [m_objectTable objectAtIndex:ref];
		}
		NSLog(@"Object reference is out of bounds");
		return [NSDate date];
	}
	NSTimeInterval time = [self _decodeDouble];
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:(time / 1000)];
	[m_objectTable addObject:date];
	return date;
}

@end



#pragma mark -



@implementation AMF3TraitsInfo

@synthesize className=m_className;
@synthesize dynamic=m_dynamic;
@synthesize externalizable=m_externalizable;
@synthesize count=m_count;
@synthesize properties=m_properties;


#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init
{
	if (self = [super init])
	{
		m_properties = [[NSMutableArray alloc] init];
		m_dynamic = NO;
		m_externalizable = NO;
	}
	return self;
}

- (void)dealloc
{
	[m_className release];
	[m_properties release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (void)addProperty:(NSString *)property
{
	[m_properties addObject:property];
}

- (BOOL)isEqual:(id)anObject
{
	if ([anObject class] != [self class])
	{
		return NO;
	}
	if ([[(AMF3TraitsInfo *)anObject className] isEqualToString:m_className] &&
		[(AMF3TraitsInfo *)anObject dynamic] == m_dynamic &&
		[(AMF3TraitsInfo *)anObject externalizable] == m_externalizable &&
		[(AMF3TraitsInfo *)anObject count] == m_count &&
		[[(AMF3TraitsInfo *)anObject properties] isEqualToArray:m_properties])
	{
		return YES;
	}
	return NO;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ = 0x%08X | className: %@ | dynamic: %d \
| externalizable: %d | count: %d>", 
		[self class], (long)self, m_className, m_dynamic, m_externalizable, m_count];
}

@end