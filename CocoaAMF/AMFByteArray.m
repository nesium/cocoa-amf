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

@interface AMF3TraitsInfo : NSObject 
{
	NSString *m_className;
	BOOL m_dynamic;
	BOOL m_externalizable;
	NSUInteger m_count;
	NSMutableArray *m_properties;
}

@property (nonatomic, retain) NSString *className;
@property (nonatomic, assign) BOOL dynamic;
@property (nonatomic, assign) BOOL externalizable;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, retain) NSMutableArray *properties;

- (void)addProperty:(NSString *)property;

@end



#pragma mark -



@interface AMFByteArray (Protected)
- (id)initWithData:(NSData *)data;
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



#pragma mark -




@implementation AMFByteArray

@synthesize position=m_position, objectEncoding=m_objectEncoding, data=m_data;

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
		m_position = 0;
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

- (uint32_t)length
{
	return [m_data length];
}

- (uint32_t)bytesAvailable
{
	return ([m_data length] - m_position);
}

//- (void)compress;

- (BOOL)readBoolean
{
	return ([self readUnsignedByte] != 0);
}

- (int8_t)readByte
{
	if (m_position >= [m_data length])
	{
		NSLog(@"read byte out of bounds.");
		return 0;
	}
	int8_t byte;
	[m_data getBytes:&byte range:(NSRange){m_position++, 1}];
	return byte;
}

- (NSData *)readBytes:(uint32_t)length
{
	if (m_position + length > [m_data length])
	{
		NSLog(@"read bytes out of bounds");
		return [NSData data];
	}
	NSData *subdata = [m_data subdataWithRange:(NSRange){m_position, length}];
	m_position += length;
	return subdata;
}

- (double)readDouble
{
	uint8_t data[8];
	data[7] = [self readUnsignedByte];
	data[6] = [self readUnsignedByte];
	data[5] = [self readUnsignedByte];
	data[4] = [self readUnsignedByte];
	data[3] = [self readUnsignedByte];
	data[2] = [self readUnsignedByte];
	data[1] = [self readUnsignedByte];
	data[0] = [self readUnsignedByte];	
	return *((double *)data);
}

- (float)readFloat
{
	uint8_t data[4];
	data[3] = [self readUnsignedByte];
	data[2] = [self readUnsignedByte];
	data[1] = [self readUnsignedByte];
	data[0] = [self readUnsignedByte];	
	return *((float *)data);
}

- (int32_t)readInt
{
	uint8_t ch1 = [self readByte];
	uint8_t ch2 = [self readByte];
	uint8_t ch3 = [self readByte];
	uint8_t ch4 = [self readByte];
	return (ch1 << 24) + (ch2 << 16) + (ch3 << 8) + ch4;
}

- (NSString *)readMultiByte:(uint32_t)length encoding:(NSStringEncoding)encoding
{
	return [[[NSString alloc] initWithData:[self readBytes:length] encoding:encoding] autorelease];
}

- (NSObject *)readObject
{
	return nil;
}

- (int16_t)readShort
{
	int8_t ch1 = [self readByte];
	int8_t ch2 = [self readByte];
	return (ch1 << 8) + ch2;
}

- (uint8_t)readUnsignedByte
{
	if (m_position >= [m_data length])
	{
		NSLog(@"read unsigned byte out of bounds.");
		return 0;
	}
	uint8_t byte;
	[m_data getBytes:&byte range:(NSRange){m_position++, 1}];
	return byte;
}

- (uint32_t)readUnsignedInt
{
	uint8_t ch1 = [self readUnsignedByte];
	uint8_t ch2 = [self readUnsignedByte];
	uint8_t ch3 = [self readUnsignedByte];
	uint8_t ch4 = [self readUnsignedByte];
	return ((ch1 & 0xFF) << 24) | ((ch2 & 0xFF) << 16) | ((ch3 & 0xFF) << 8) | (ch4 & 0xFF);
}

- (uint16_t)readUnsignedShort
{
	int8_t ch1 = [self readByte];
	int8_t ch2 = [self readByte];
	return ((ch1 & 0xFF) << 8) | (ch2 & 0xFF);
}

- (NSString *)readUTF
{
	return [self readUTFBytes:[self readUnsignedShort]];
}

- (NSString *)readUTFBytes:(uint32_t)length
{
	if (length == 0)
	{
		return [NSString string];
	}
	return [[[NSString alloc] initWithData:[self readBytes:length] 
		encoding:NSUTF8StringEncoding] autorelease];
}

// - (void)uncompress;

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

- (NSObject *)readObject
{
	AMF0Type type = (AMF0Type)[self readUnsignedByte];
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
			value = [NSNumber numberWithDouble:[self readDouble]];
			break;
			
		case kAMF0BooleanType:
			value = [NSNumber numberWithBool:[self readBoolean]];
			break;
			
		case kAMF0StringType:
			value = [self readUTF];
			break;
			
		case kAMF0AVMPlusObjectType:
			if (m_avmPlusByteArray == nil)
			{
				m_avmPlusByteArray = [[AMFByteArray alloc] initWithData:m_data 
					encoding:kAMF3Version];
			}
			m_avmPlusByteArray.position = m_position;
			value = [m_avmPlusByteArray readObject];
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
	uint32_t size = [self readUnsignedInt];
	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:size];
	for (uint32_t i = 0; i < size; i++)
	{
		NSObject *obj = [self readObject];
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
	NSString *className = [self readUTF];
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
	
	NSString *propertyName = [self readUTF];
	AMF0Type type = [self readUnsignedByte];
	while (type != kAMF0ObjectEndType)
	{
		[object setValue:[self readObjectWithType:type] forKey:propertyName];
		propertyName = [self readUTF];
		type = [self readUnsignedByte];
	}
	
	return object;
}

- (NSString *)readLongString
{
	uint32_t length = [self readUnsignedInt];
	if (length == 0)
	{
		return [NSString string];
	}
	return [self readUTFBytes:length];
}

- (NSString *)readXML
{
	//@FIXME
	return [self readLongString];
}

- (NSDate *)readDate
{
	NSTimeInterval time = [self readDouble];
	// timezone
	[self readUnsignedShort];
	return [NSDate dateWithTimeIntervalSince1970:(time / 1000)];
}

- (NSDictionary *)readECMAArray
{
	uint32_t size = [self readUnsignedInt];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:size];
	[m_objectTable addObject:dict];
	[dict release];
	
	NSString *propertyName = [self readUTF];
	AMF0Type type = [self readUnsignedByte];
	while (type != kAMF0ObjectEndType)
	{
		[dict setValue:[self readObjectWithType:type] forKey:propertyName];
		propertyName = [self readUTF];
		type = [self readUnsignedByte];
	}
	return dict;
}

- (NSObject *)readReference
{
	uint16_t index = [self readUnsignedShort];
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
	uint8_t ch = [self readUnsignedByte] & 0xFF;
	
	if (ch < 128)
	{
		return ch;
	}
	
	value = (ch & 0x7F) << 7;
	ch = [self readUnsignedByte] & 0xFF;
	if (ch < 128)
	{
		return value | ch;
	}
	
	value = (value | (ch & 0x7F)) << 7;
	ch = [self readUnsignedByte] & 0xFF;
	if (ch < 128)
	{
		return value | ch;
	}
	
	value = (value | (ch & 0x7F)) << 8;
	ch = [self readUnsignedByte] & 0xFF;
	return value | ch;
}

- (NSObject *)readObject
{
	AMF3Type type = (AMF3Type)[self readUnsignedByte];
	return [self readObjectWithType:type];
}

- (NSString *)readUTF
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
	NSString *value = [self readUTFBytes:length];
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
			value = [self readUTF];
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
			value = [NSNumber numberWithDouble:[self readDouble]];
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
		[object setValue:[self readObject] forKey:property];
	}
	
	if (traitsInfo.dynamic)
	{
		property = [self readUTF];
		while (property != nil && [property length] > 0)
		{
			[object setValue:[self readObject] forKey:property];
			property = [self readUTF];
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
		NSString *name = [self readUTF];
		if (name == nil || [name length] == 0) 
		{
			break;
		}
		
		if (array == nil)
		{
			array = [NSMutableDictionary dictionary];
		}
		[(NSMutableDictionary *)array setObject:[self readObject] forKey:name];
	}
	
	if (array == nil)
	{
		array = [NSMutableArray array];
		for (uint32_t i = 0; i < length; i++)
		{
			[(NSMutableArray *)array addObject:[self readObject]];
		}
	}
	else
	{
		for (uint32_t i = 0; i < length; i++)
		{
			[(NSMutableDictionary *)array setObject:[self readObject] 
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
	NSString *className = [self readUTF];
	
	AMF3TraitsInfo *info = [[AMF3TraitsInfo alloc] init];
	info.className = className;
	info.dynamic = dynamic;
	info.externalizable = externalizable;
	info.count = count;
	while (count--)
	{
		[info addProperty:[self readUTF]];
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
	return [self readUTF];
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
	NSTimeInterval time = [self readDouble];
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:(time / 1000)];
	[m_objectTable addObject:date];
	return date;
}

@end