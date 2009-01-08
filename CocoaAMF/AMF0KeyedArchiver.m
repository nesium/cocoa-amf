//
//  AMFCoder.m
//  SimpleHTTPServer
//
//  Created by Marc Bauer on 12.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "AMF0KeyedArchiver.h"

@interface AMF0KeyedArchiver (Private)
- (void)writeObject:(id)obj;
@end


@implementation AMF0KeyedArchiver


#pragma mark -
#pragma mark Initialization & Deallocation

+ (NSData *)archivedDataWithRootObject:(id)rootObject
{
	AMF0KeyedArchiver *archiver = [[[self class] alloc] 
		initForWritingWithMutableData:[NSMutableData data]];
	[archiver encodeRootObject:rootObject];
	[archiver finishEncoding];
	NSData *archivedData = [archiver->m_byteArray.data copy];
	return [archivedData autorelease];
}

- (id)initForWritingWithMutableData:(NSMutableData *)data
{
	if (self = [super init])
	{
		m_byteArray = [[AMFByteArray alloc] initWithData:data encoding:kAMF0Version];
		m_currentStack = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initForWritingWithByteArray:(AMFByteArray *)byteArray
{
	if (self = [super init])
	{
		m_byteArray = [byteArray retain];
		m_currentStack = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[m_byteArray release];
	[m_currentStack release];
	[super dealloc];
}

- (void)_encodePropertyList:plist forKey:(NSString *)key
{
	//NSLog(@"%s: plist = %@  key = %@", __FUNCTION__, plist, key);
}


#pragma mark -
#pragma mark Public methods

- (void)encodeValueOfObjCType:(const char *)valueType at:(const void *)address
{
	//NSLog(@"encode valueOfObjCType %s", valueType);
	
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
	//NSLog(@"encode object (%@) for key %@", [obj className], key);
	
	ASObject *currentObject = [m_currentStack lastObject];

	if (currentObject != nil)
	{
		[currentObject setValue:obj forKey:key];
	}
	
	if (![obj isKindOfClass:[NSString class]] && 
		![obj isKindOfClass:[NSArray class]] && 
		![obj isKindOfClass:[NSDictionary class]] &&
		![obj isKindOfClass:[NSDate class]] &&
		![obj isKindOfClass:[NSNumber class]] &&
		![obj isKindOfClass:[ASObject class]])
	{
		// create new as object
		ASObject *asObj = [[ASObject alloc] init];
		asObj.type = [obj className];
		//NSLog(@"encode ASObject %@", [obj className]);
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
	//NSLog(@"encodeBytes for key: %@", key);
}

- (BOOL)allowsKeyedCoding
{
	return YES;
}

- (void)encodeDataObject:(NSData *)data
{
	//NSLog(@"encode data object");
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
	[self encodeObject:[NSNumber numberWithLongLong:arg] forKey:key];
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
		[(AMF0ByteArray *)m_byteArray writeString:(NSString *)obj omitType:NO];
	}
	else if ([obj isKindOfClass:[NSArray class]])
	{
		[(AMF0ByteArray *)m_byteArray writeArray:(NSArray *)obj];
	}
	else if ([obj isKindOfClass:[NSDictionary class]])
	{
		[(AMF0ByteArray *)m_byteArray writeECMAArray:(NSDictionary *)obj];
	}
	else if ([obj isKindOfClass:[NSDate class]])
	{
		[(AMF0ByteArray *)m_byteArray writeDate:(NSDate *)obj];
	}
	else if ([obj isKindOfClass:[NSNumber class]])
	{
		[(AMF0ByteArray *)m_byteArray writeNumber:(NSNumber *)obj];
	}
	else if ([obj isKindOfClass:[ASObject class]])
	{
		[(AMF0ByteArray *)m_byteArray writeASObject:(ASObject *)obj];
	}
	else
	{
		[self encodeObject:obj forKey:nil];
	}
}

@end