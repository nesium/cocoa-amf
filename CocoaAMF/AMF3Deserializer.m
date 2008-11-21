//
//  AMF3Deserializer.m
//  CocoaAMF
//
//  Created by Marc Bauer on 07.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "AMF3Deserializer.h"

@interface AMF3Deserializer (Private)
- (NSString *)readString;
- (id)readObject;
- (id)readArray;
- (NSDate *)readDate;
- (NSData *)readByteArray;
- (NSString *)readXML;
- (AMF3TraitsInfo *)readTraits:(NSUInteger)infoBits;
- (void)readExternalizableWithClassName:(NSString *)aClassName object:(NSObject *)object;
@end


@implementation AMF3Deserializer

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithStream:(AMFInputStream *)stream
{
	if (self = [super initWithStream:stream])
	{
		m_stringTable = [[NSMutableArray alloc] init];
		m_objectTable = [[NSMutableArray alloc] init];
		m_traitsTable = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[m_stringTable release];
	[m_objectTable release];
	[m_traitsTable release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (id)deserialize
{
	AMF3Type type = (AMF3Type)[m_stream readUInt8];
	
	id value = nil;
	NSUInteger intValue;
	
	NSLog(@"type: %d", type);
	
	switch (type)
	{
		case kAMF3StringType:
			NSLog(@"read string");
			value = [self readString];
			break;
		
		case kAMF3ObjectType:
			NSLog(@"read object");
			value = [self readObject];
			break;
			
		case kAMF3ArrayType:
			NSLog(@"read array");
			value = [self readArray];
			break;
			
		case kAMF3FalseType:
			NSLog(@"read boolean - false");
			value = [NSNumber numberWithBool:NO];
			break;
			
		case kAMF3TrueType:
			NSLog(@"read boolean - true");
			value = [NSNumber numberWithBool:YES];
			break;
			
		case kAMF3IntegerType:
			NSLog(@"read integer");
			intValue = [m_stream readUInt29];
			intValue = (intValue << 3) >> 3;
			value = [NSNumber numberWithInt:intValue];
			break;
			
		case kAMF3DoubleType:
			NSLog(@"read double");
			value = [NSNumber numberWithDouble:[m_stream readDouble]];
			break;
			
		case kAMF3UndefinedType:
			NSLog(@"read undefined");
			return [NSNull null];
			break;
			
		case kAMF3NullType:
			NSLog(@"read null");
			return [NSNull null];
			break;
			
		case kAMF3XMLType:
		case kAMF3XMLDocType:
			NSLog(@"read xml");
			value = [self readXML];
			break;
			
		case kAMF3DateType:
			NSLog(@"read date");
			value = [self readDate];
			break;
			
		case kAMF3ByteArrayType:
			NSLog(@"read bytearray");
			value = [self readByteArray];
			break;
			
		default:
			NSLog(@"Can not decode unknown type");
			// throw exception here
			break;
	}
	return value;
}

- (NSString *)readString
{
	NSUInteger ref = [m_stream readUInt29];
	
	if ((ref & 1) == 0)
	{
		NSLog(@"try reading string reference");
		return (NSString *)[m_stringTable objectAtIndex:(ref >> 1)];
	}
	
	NSUInteger len = (ref >> 1);
	NSLog(@"read string with length %d", len);
	if (len == 0)
	{
		return [NSString string];
	}
	NSString *value = [m_stream readUTF8:len];
	[m_stringTable addObject:value];
	return value;
}



#pragma mark -
#pragma mark Private methods

- (id)readObject
{
	NSUInteger ref = [m_stream readUInt29];
	if ((ref & 1) == 0)
	{
		return [m_objectTable objectAtIndex:(ref >> 1)];
	}
	
	AMF3TraitsInfo *traitsInfo = [self readTraits:ref];
	NSLog(@"%@", traitsInfo);
	NSObject *object;
	if (traitsInfo.className == nil || [traitsInfo.className length] == 0)
	{
		NSLog(@"-> 1");
		object = [[[ASObject alloc] init] autorelease];
	}
	else if ([[traitsInfo.className substringToIndex:1] isEqualToString:@">"])
	{
		NSLog(@"-> 2");
		object = [[[ASObject alloc] init] autorelease];
		[(ASObject *)object setType:traitsInfo.className];
	}
	else
	{
		Class deserializedObjectClass = objc_getClass([traitsInfo.className 
			cStringUsingEncoding:NSUTF8StringEncoding]);
		if (deserializedObjectClass == nil)
		{
			NSLog(@"-> 3");
			object = [[[ASObject alloc] init] autorelease];
			[(ASObject *)object setType:traitsInfo.className];
		}
		else
		{
			NSLog(@"-> 4");
			object = [[[deserializedObjectClass alloc] init] autorelease];
		}
	}
	
	[m_objectTable addObject:object];
	
	if (traitsInfo.externalizable)
	{
		[self readExternalizableWithClassName:traitsInfo.className object:object];
		return object;
	}
	
	NSEnumerator *propertiesEnumerator = [traitsInfo.properties objectEnumerator];
	NSString *property;
	while (property = [propertiesEnumerator nextObject])
	{
		[object setValue:[self deserialize] forKey:property];
	}
	
	if (traitsInfo.dynamic)
	{
		property = [self readString];
			NSLog(@"property: %@", property);
		while (property != nil && [property length] > 0)
		{
			NSLog(@"property: %@", property);
			[object setValue:[self deserialize] forKey:property];
			property = [self readString];
		}
	}
	NSLog(@"read object: %@", object);
	return object;
}

- (id)readArray
{
	NSUInteger ref = [m_stream readUInt29];
	
	if ((ref & 1) == 0)
	{
		return [m_objectTable objectAtIndex:(ref >> 1)];
	}
	
	NSUInteger len = (ref >> 1);
	id array = nil;
	for (;;)
	{
		NSString *name = [self readString];
		if (name == nil || [name length] == 0) break;
		
		if (array == nil)
		{
			array = [[[NSMutableDictionary alloc] init] autorelease];
			[m_objectTable addObject:array];
		}
		[(NSMutableDictionary *)array setObject:[self deserialize] forKey:name];
	}
	
	if (array == nil)
	{
		array = [[[NSMutableArray alloc] init] autorelease];
		[m_objectTable addObject:array];
		NSUInteger i = 0;
		for (; i < len; i++)
		{
			[(NSMutableArray *)array addObject:[self deserialize]];
		}
	}
	else
	{
		NSUInteger i = 0;
		for (; i < len; i++)
		{
			[(NSMutableDictionary *)array setObject:[self deserialize] 
				forKey:[NSNumber numberWithInt:i]];
		}
	}
	return array;
}

- (NSDate *)readDate
{
	uint32_t ref = [m_stream readUInt29];
	
	if ((ref & 1) == 0)
	{
		return [m_objectTable objectAtIndex:(ref >> 1)];
	}
	
	NSTimeInterval time = [m_stream readDouble];
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:(time / 1000)];
	[m_objectTable addObject:date];
	return date;
}

- (NSData *)readByteArray
{
	uint32_t ref = [m_stream readUInt29];
	
	if ((ref & 1) == 0)
	{
		return [m_objectTable objectAtIndex:(ref >> 1)];
	}
	
	uint32_t len = (ref >> 1);
	NSData *data = [m_stream readDataWithLength:len];

	// deserialize bytearray
//	[data writeToFile:@"/Users/mb/Desktop/ByteArray.amf" atomically:NO];	
//	AMFInputStream *stream = [[AMFInputStream alloc] initWithData:data];
//	AMF3Deserializer *deserializer = [[AMF3Deserializer alloc] initWithStream:stream];
//	NSLog(@"deserialize: %@", [deserializer deserialize]);
//	[stream release];
//	[deserializer release];
	
	return data;
}

- (NSString *)readXML
{
	return [self readString];
}

- (AMF3TraitsInfo *)readTraits:(NSUInteger)infoBits
{
	if ((infoBits & 3) == 1)
	{
		return [m_traitsTable objectAtIndex:(infoBits >> 2)];
	}
	
	BOOL externalizable = (infoBits & 4) == 4;
	BOOL dynamic = (infoBits & 8) == 8;
	NSUInteger count = infoBits >> 4;
	NSString *className = [self readString];
	
	AMF3TraitsInfo *info = [[AMF3TraitsInfo alloc] init];
	info.className = className;
	info.dynamic = dynamic;
	info.externalizable = externalizable;
	info.count = count;
	
	NSLog(@"temporary traits info: %@ / num props: %d", info, count);
	
	while (count--)
	{
		[info addProperty:[self readString]];
	}
	
	[m_traitsTable addObject:info];
	[info release];
	
	return info;
}

- (void)readExternalizableWithClassName:(NSString *)aClassName object:(NSObject *)object
{
	NSLog(@"should read externalizable for class %@", aClassName);
}

@end