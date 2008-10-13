//
//  AMF0Deserializer.m
//  CocoaAMF
//
//  Created by Marc Bauer on 11.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "AMF0Deserializer.h"

@interface AMF0Deserializer (Private)
- (id)deserializedObjectWithType:(AMF0Type)type;
- (NSString *)readString;
- (NSString *)readLongString;
- (NSArray *)readArray;
- (id)readObject:(NSString *)className;
- (NSDictionary *)readECMAArray;
- (NSDate *)readDate;
- (NSString *)readXML;
@end


@implementation AMF0Deserializer

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithStream:(AMFInputStream *)stream
{
	if (self = [super initWithStream:stream])
	{
		m_objectTable = [[NSMutableArray alloc] init];
		m_avmPlusDeserializer = nil;
	}
	return self;
}

- (void)dealloc
{
	[m_objectTable release];
	[m_avmPlusDeserializer release];
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (id)deserialize
{
	AMF0Type type = (AMF0Type)[m_stream readUInt8];
	return [self deserializedObjectWithType:type];
}



#pragma mark -
#pragma mark Private methods

- (id)deserializedObjectWithType:(AMF0Type)type
{
	id value = nil;
	
	BOOL bFlag;
	NSString *className;
	uint16_t ref;
	
	NSLog(@"type: %d", type);
	
	switch (type)
	{
		case kAMF0NumberType:
			NSLog(@"AMF0 read number");
			value = [NSNumber numberWithDouble:[m_stream readDouble]];
			break;
			
		case kAMF0BooleanType:
			NSLog(@"AMF0 read boolean");
			bFlag = [m_stream readBool];
			value = [NSValue valueWithBytes:&bFlag objCType:@encode(BOOL)];
			break;
			
		case kAMF0StringType:
			NSLog(@"AMF0 read string");
			value = [self readString];
			break;
			
		case kAMF0AVMPlusObjectType:
			NSLog(@"AMF0 read avmplusobject");
			if (!m_avmPlusDeserializer)
			{
				m_avmPlusDeserializer = [[AMF3Deserializer alloc] initWithStream:m_stream];
			}
			value = [m_avmPlusDeserializer deserialize];
			break;
		
		case kAMF0StrictArrayType:
			NSLog(@"AMF0 read strict array");
			value = [self readArray];
			break;
			
		case kAMF0TypedObjectType:
			NSLog(@"AMF0 read typed object");
			className = [self readString];
			value = [self readObject:className];
			break;
		
		case kAMF0LongStringType:
			NSLog(@"AMF0 read long string");
			value = [self readLongString];
			break;
			
		case kAMF0ObjectType:
			NSLog(@"AMF0 read object");
			value = [self readObject:nil];
			break;
			
		case kAMF0XMLObjectType:
			NSLog(@"AMF0 read xml");
			value = [self readXML];
			break;
			
		case kAMF0NullType:
			NSLog(@"AMF0 read null");
			value = [NSNull null];
			break;
			
		case kAMF0DateType:
			NSLog(@"AMF0 read date");
			value = [self readDate];
			break;
			
		case kAMF0ECMAArrayType:
			NSLog(@"AMF0 read ecma array");
			value = [self readECMAArray];
			break;
			
		case kAMF0ReferenceType:
			NSLog(@"AMF0 read reference");
			ref = [m_stream readUInt16];
			value = [m_objectTable objectAtIndex:ref];
			break;
		
		case kAMF0UndefinedType:
			NSLog(@"AMF0 read undefined");
			value = [NSNull null];
			break;
		
		case kAMF0UnsupportedType:
			NSLog(@"Unsupported type!");
			break;
			
		case kAMF0ObjectEndType:
			NSLog(@"Unexpected object end!");
			break;
		
		case kAMF0RecordsetType:
			NSLog(@"Unexpected Recordset!");
			break;
		
		default:
			NSLog(@"Can not decode unknown type");
			// throw exception here
			break;
	}
	
	NSLog(@"value: %@", value);
	return value;
}

- (NSString *)readString
{
	uint16_t len = [m_stream readUInt16];
	if (len == 0)
	{
		return [NSString string];
	}
	return [m_stream readUTF8:len];
}

- (NSString *)readLongString
{
	uint32_t len = [m_stream readUInt32];
	if (len == 0)
	{
		return [NSString string];
	}
	return [m_stream readUTF8:len];
}

- (NSArray *)readArray
{
	uint32_t size = [m_stream readUInt32];
	uint32_t i = 0;
	NSMutableArray *array = [[[NSMutableArray alloc] initWithCapacity:size] autorelease];
	NSLog(@"read array with length: %d", size);
	for (; i < size; i++)
	{
		[array addObject:[self deserialize]];
	}
	[m_objectTable addObject:array];
	return array;
}

- (id)readObject:(NSString *)className
{
	NSObject *object;
	
	if (className == nil || [className length] == 0)
	{
		NSLog(@"-> 1");
		object = [[[ASObject alloc] init] autorelease];
	}
	else if ([[className substringToIndex:1] isEqualToString:@">"])
	{
		NSLog(@"-> 2");
		object = [[[ASObject alloc] init] autorelease];
		[(ASObject *)object setType:className];
	}
	else
	{
		Class deserializedObjectClass = objc_getClass([className 
			cStringUsingEncoding:NSUTF8StringEncoding]);
		if (deserializedObjectClass == nil)
		{
			NSLog(@"-> 3");
			object = [[[ASObject alloc] init] autorelease];
			[(ASObject *)object setType:className];
		}
		else
		{
			NSLog(@"-> 4");
			object = [[[deserializedObjectClass alloc] init] autorelease];
		}
	}
	
	[m_objectTable addObject:object];
	
	NSString *propertyName = [self readString];
	AMF0Type type = [m_stream readUInt8];
	while (type != kAMF0ObjectEndType)
	{
		[object setValue:[self deserializedObjectWithType:type] forKey:propertyName];
		propertyName = [self readString];
		type = [m_stream readUInt8];
	}
	
	return object;
}

- (NSDictionary *)readECMAArray
{
	uint32_t size = [m_stream readUInt32];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithCapacity:size] 
		autorelease];
	[m_objectTable addObject:dict];
	
	NSString *propertyName = [self readString];
	AMF0Type type = [m_stream readUInt8];
	while (type != kAMF0ObjectEndType)
	{
		[dict setValue:[self deserializedObjectWithType:type] forKey:propertyName];
		propertyName = [self readString];
		type = [m_stream readUInt8];
	}
	return dict;
}

- (NSDate *)readDate
{
	NSTimeInterval time = [m_stream readDouble];
	// timezone
	[m_stream readUInt16];
	return [NSDate dateWithTimeIntervalSince1970:(time / 1000)];
}

- (NSString *)readXML
{
	return [self readLongString];
}

@end