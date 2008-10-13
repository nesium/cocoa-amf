//
//  AMFCoder.m
//  SimpleHTTPServer
//
//  Created by Marc Bauer on 12.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "AMFKeyedArchiver.h"


@interface AMFKeyedArchiver (Private)
- (void)writeObject:(id)obj;
- (void)writeUInt8:(uint8_t)value;
- (void)writeUInt16:(uint16_t)value;
- (void)writeUInt29:(uint32_t)value;
- (void)writeUInt32:(uint32_t)value;
- (void)writeDouble:(double)value;
- (void)writeData:(NSData *)value;
- (void)writeString:(NSString *)value omitType:(BOOL)omitType;
- (void)writeArray:(NSArray *)value;
- (void)writeECMAArray:(NSDictionary *)value;
- (void)writeASObject:(ASObject *)obj;
- (void)writeNumber:(NSNumber *)value;
- (void)writeDate:(NSDate *)value;
@end



@implementation AMFKeyedArchiver

@synthesize version=m_version;


#pragma mark -
#pragma mark Initialization & Deallocation

+ (NSData *)archivedDataWithRootObject:(id)rootObject
{
	AMFKeyedArchiver *archiver = [[AMFKeyedArchiver alloc] 
		initForWritingWithMutableData:[NSMutableData data]];
	[archiver encodeRootObject:rootObject];
	[archiver finishEncoding];
	NSData *archivedData = [archiver->m_data copy];
	return [archivedData autorelease];
}

- (id)initForWritingWithMutableData:(NSMutableData *)data
{
	if (self = [super init])
	{
		m_data = [data retain];
		m_currentStack = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[m_data release];
	[m_currentStack release];
	[super dealloc];
}

- (void)_encodePropertyList:plist forKey:(NSString *)key
{
	NSLog(@"%s: plist = %@  key = %@", __FUNCTION__, plist, key);
}


#pragma mark -
#pragma mark Public methods

- (void)encodeValueOfObjCType:(const char *)valueType at:(const void *)address
{
	NSLog(@"encode valueOfObjCType %s", valueType);
	
	switch (valueType[0])
	{
		case '@': // Object
		case '#': // Class
			[self encodeObject:*((id *)address) forKey:nil];
			break;
		case ':': // Selector
			[self encodeObject:NSStringFromSelector(*((SEL *)address)) forKey:nil];
			break;
		default:
			break;
	}
}

- (void)encodeObject:(id)obj forKey:(NSString *)key
{
	NSLog(@"encode object (%@) for key %@", [obj className], key);
	
	ASObject *currentObject = [m_currentStack lastObject];

	if (currentObject != nil)
	{
		[currentObject setValue:obj forKey:key];
	}
	
	if (![obj isKindOfClass:[NSString class]] && 
		![obj isKindOfClass:[NSArray class]] && 
		![obj isKindOfClass:[NSDictionary class]] &&
		![obj isKindOfClass:[NSDate class]] &&
		![obj isKindOfClass:[NSNumber class]])
	{
		NSLog(@"HELLO!");
	
		// create new as object
		ASObject *asObj = [[ASObject alloc] init];
		asObj.type = [obj className];
		NSLog(@"encode ASObject %@", [obj className]);
		// add to stack
		[m_currentStack addObject:asObj];
		// encode subobjects
		[obj encodeWithCoder:self];
		// remove from stack
		[m_currentStack removeLastObject];
		// write if stack is empty
		[m_currentStack count] > 0 ?: [self writeObject:asObj];
		[asObj release];
	}
	else
	{
		if (currentObject == nil)
		{
			[self writeObject:obj];
			return;
		}
	}
}

- (void)encodeBytes:(const uint8_t *)bytesp length:(unsigned)lenv forKey:(NSString *)key
{
	NSLog(@"encodeBytes for key: %@", key);
}

- (BOOL)allowsKeyedCoding
{
	return YES;
}

- (void)encodeDataObject:(NSData *)data
{
	NSLog(@"encode data object");
}

- (void)encodeBool:(BOOL)arg forKey:(NSString *)key
{
	[self encodeObject:[NSNumber numberWithBool:arg] forKey:key];
}

- (void)encodeInt:(int)arg forKey:(NSString *)key
{
	[self encodeObject:[NSNumber numberWithInt:arg] forKey:key];
}

- (void)encodeInt32:(int32_t)arg forKey:(NSString *)key
{
	[self encodeObject:[NSNumber numberWithInt:arg] forKey:key];
}

- (void)encodeInt64:(int64_t)arg forKey:(NSString *)key
{
	[self encodeObject:[NSNumber numberWithLongLong:arg forKey:key]];
}

- (void)encodeFloat:(float)arg forKey:(NSString *)key
{
	[self encodeObject:[NSNumber numberWithFloat:arg] forKey:key];
}

- (void)encodeDouble:(double)arg forKey:(NSString *)key
{
	[self encodeObject:[NSNumber numberWithDouble:arg] forKey:key];
}

- (void)finishEncoding
{
	
}



#pragma mark -
#pragma mark Private methods

- (void)writeObject:(id)obj
{
	if ([obj isKindOfClass:[NSString class]])
	{
		[self writeString:(NSString *)obj omitType:NO];
	}
	else if ([obj isKindOfClass:[NSArray class]])
	{
		[self writeArray:(NSArray *)obj];
	}
	else if ([obj isKindOfClass:[NSDictionary class]])
	{
		[self writeECMAArray:(NSDictionary *)obj];
	}
	else if ([obj isKindOfClass:[NSDate class]])
	{
		[self writeDate:(NSDate *)obj];
	}
	else if ([obj isKindOfClass:[NSNumber class]])
	{
		[self writeNumber:(NSNumber *)obj];
	}
	else if ([obj isKindOfClass:[ASObject class]])
	{
		[self writeASObject:(ASObject *)obj];
	}
	else
	{
		[self encodeObject:obj forKey:nil];
	}
}

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
	double *ptr1 = &value;
	void *tmp = ptr1;
	uint8_t *ptr2 = tmp;
	[self writeUInt8:ptr2[7]];
	[self writeUInt8:ptr2[6]];
	[self writeUInt8:ptr2[5]];
	[self writeUInt8:ptr2[4]];
	[self writeUInt8:ptr2[3]];
	[self writeUInt8:ptr2[2]];
	[self writeUInt8:ptr2[1]];
	[self writeUInt8:ptr2[0]];
}

- (void)writeData:(NSData *)value
{
	[m_data appendData:value];
}

- (void)writeString:(NSString *)value omitType:(BOOL)omitType
{
	NSData *stringData = [value dataUsingEncoding:NSUTF8StringEncoding];
	
	if ([stringData length] > 0xFFFF)
	{
		omitType ?: [self writeUInt8:kAMF0LongStringType];
		[self writeUInt32:[stringData length]];
	}
	else
	{
		omitType ?: [self writeUInt8:kAMF0StringType];
		[self writeUInt16:[stringData length]];
	}
	
	[self writeData:stringData];
}

- (void)writeArray:(NSArray *)value
{
	[self writeUInt8:kAMF0StrictArrayType];
	[self writeUInt32:[value count]];
	for (id obj in value)
	{
		[self writeObject:obj];
	}
}

- (void)writeECMAArray:(NSDictionary *)value
{
	[self writeUInt8:kAMF0ECMAArrayType];
	[self writeUInt32:[value count]];
	for (NSString *key in value)
	{
		[self writeString:key omitType:YES];
		[self writeObject:[value objectForKey:key]];
	}
	[self writeUInt16:0];
	[self writeUInt8:kAMF0ObjectEndType];
}

- (void)writeASObject:(ASObject *)obj
{
	if (obj.type == nil)
	{
		[self writeUInt8:kAMF0ObjectType];
		[self writeUInt16:0];
	}
	else
	{
		[self writeUInt8:kAMF0TypedObjectType];
		[self writeString:obj.type omitType:YES];
	}
	for (NSString *key in obj.properties)
	{
		[self writeString:key omitType:YES];
		[self writeObject:[obj valueForKey:key]];
	}
	[self writeUInt16:0];
	[self writeUInt8:kAMF0ObjectEndType];
}

- (void)writeNumber:(NSNumber *)value
{
	if ([[value className] isEqualToString:@"NSCFBoolean"])
	{
		[self writeUInt8:kAMF0BooleanType];
		[self writeUInt8:[value boolValue]];
		return;
	}
	[self writeUInt8:kAMF0NumberType];
	[self writeDouble:[value doubleValue]];
}

- (void)writeDate:(NSDate *)value
{
	[self writeUInt8:kAMF0DateType];
	[self writeDouble:([value timeIntervalSince1970] * 1000)];
	[self writeUInt16:([[NSTimeZone localTimeZone] secondsFromGMT] / 60)];
}

@end