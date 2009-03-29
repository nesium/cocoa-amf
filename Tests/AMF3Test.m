//
//  AMF3Test.m
//  CocoaAMF
//
//  Created by Marc Bauer on 20.02.09.
//  Copyright 2009 Fork Unstable Media GmbH. All rights reserved.
//

#import "AMF3Test.h"

@implementation WrongSerializedCustomObject

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:@"foo"];
	[coder encodeObject:@"foo" forKey:@"bar"];
}
@end

@implementation PlainStringEncoder

- (id)init
{
	if (self = [super init])
	{
		m_string = [@"Hello World" retain];
	}
	return self;
}

- (void)dealloc
{
	[m_string release];
	[super dealloc];
}

- (BOOL)isEqual:(id)obj
{
	if (![obj isMemberOfClass:[self class]])
	{
		return NO;
	}
	return [((PlainStringEncoder *)obj)->m_string isEqual:m_string];
}

- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super init])
	{
		m_string = [[(AMFUnarchiver *)coder decodeUTFBytes:11] retain];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[(AMFArchiver *)coder encodeUTFBytes:m_string];
}
@end





@implementation AMF3Test

- (void)testNumber
{
	NSNumber *num = [NSNumber numberWithInt:0];
	STAssertTrue([self assertDataOfFile:@"number_0.amf3" 
		isEqualTo:num], @"Numbers do not match");
		
	STAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_0.amf3"], 
		@"Number data is not equal");
		
	num = [NSNumber numberWithInt:0x35];
	STAssertTrue([self assertDataOfFile:@"number_1.amf3" 
		isEqualTo:num], @"Numbers do not match");
		
	STAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_1.amf3"], 
		@"Number data is not equal");
		
	num = [NSNumber numberWithInt:0x7f];
	STAssertTrue([self assertDataOfFile:@"number_2.amf3" 
		isEqualTo:num], @"Numbers do not match");
		
	STAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_2.amf3"], 
		@"Number data is not equal");
		
	num = [NSNumber numberWithInt:0x80];
	STAssertTrue([self assertDataOfFile:@"number_3.amf3" 
		isEqualTo:num], @"Numbers do not match");
		
	STAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_3.amf3"], 
		@"Number data is not equal");
		
	num = [NSNumber numberWithInt:0xd4];
	STAssertTrue([self assertDataOfFile:@"number_4.amf3" 
		isEqualTo:num], @"Numbers do not match");
		
	STAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_4.amf3"], 
		@"Number data is not equal");
		
	num = [NSNumber numberWithInt:0x3fff];
	STAssertTrue([self assertDataOfFile:@"number_5.amf3" 
		isEqualTo:num], @"Numbers do not match");
		
	STAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_5.amf3"], 
		@"Number data is not equal");
		
	num = [NSNumber numberWithInt:0x4000];
	STAssertTrue([self assertDataOfFile:@"number_6.amf3" 
		isEqualTo:num], @"Numbers do not match");
		
	STAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_6.amf3"], 
		@"Number data is not equal");
		
	num = [NSNumber numberWithInt:0x1a53f];
	STAssertTrue([self assertDataOfFile:@"number_7.amf3" 
		isEqualTo:num], @"Numbers do not match");
		
	STAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_7.amf3"], 
		@"Number data is not equal");
		
	num = [NSNumber numberWithInt:0x1fffff];
	STAssertTrue([self assertDataOfFile:@"number_8.amf3" 
		isEqualTo:num], @"Numbers do not match");
		
	STAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_8.amf3"], 
		@"Number data is not equal");
		
	num = [NSNumber numberWithInt:0x200000];
	STAssertTrue([self assertDataOfFile:@"number_9.amf3" 
		isEqualTo:num], @"Numbers do not match");
		
	STAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_9.amf3"], 
		@"Number data is not equal");
		
	num = [NSNumber numberWithInt:-0x01];
	STAssertTrue([self assertDataOfFile:@"number_10.amf3" 
		isEqualTo:num], @"Numbers do not match");
		
	STAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_10.amf3"], 
		@"Number data is not equal");
		
	num = [NSNumber numberWithInt:-0x2a];
	STAssertTrue([self assertDataOfFile:@"number_11.amf3" 
		isEqualTo:num], @"Numbers do not match");
		
	STAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_11.amf3"], 
		@"Number data is not equal");
		
	num = [NSNumber numberWithInt:0xfffffff];
	STAssertTrue([self assertDataOfFile:@"number_12.amf3" 
		isEqualTo:num], @"Numbers do not match");
		
	STAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_12.amf3"], 
		@"Number data is not equal");
		
	num = [NSNumber numberWithInt:-0x10000000];
	STAssertTrue([self assertDataOfFile:@"number_13.amf3" 
		isEqualTo:num], @"Numbers do not match");
		
	STAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_13.amf3"], 
		@"Number data is not equal");
		
	num = [NSNumber numberWithDouble:0x10000000];
	STAssertTrue([self assertDataOfFile:@"number_14.amf3" 
		isEqualTo:num], @"Numbers do not match");
		
	STAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_14.amf3"], 
		@"Number data is not equal");
		
	num = [NSNumber numberWithDouble:-0x10000001];
	STAssertTrue([self assertDataOfFile:@"number_15.amf3" 
		isEqualTo:num], @"Numbers do not match");
		
	STAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_15.amf3"], 
		@"Number data is not equal");
	
	num = [NSNumber numberWithDouble:0.1];
	STAssertTrue([self assertDataOfFile:@"number_16.amf3" 
		isEqualTo:num], @"Numbers do not match");
		
	STAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_16.amf3"], 
		@"Number data is not equal");
	
	num = [NSNumber numberWithDouble:0.123456789];
	STAssertTrue([self assertDataOfFile:@"number_17.amf3" 
		isEqualTo:num], @"Numbers do not match");
		
	STAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_17.amf3"], 
		@"Number data is not equal");
}

- (void)testBoolean
{
	STAssertTrue([self assertDataOfFile:@"boolean_0.amf3" 
		isEqualTo:[NSNumber numberWithBool:YES]], @"Booleans do not match");
		
	STAssertTrue([self assertEncodedObject:[NSNumber numberWithBool:YES] 
		isEqualToContentsOfFile:@"boolean_0.amf3"], @"Boolean data is not equal");
		
	STAssertTrue([self assertDataOfFile:@"boolean_1.amf3" 
		isEqualTo:[NSNumber numberWithBool:NO]], @"Booleans do not match");
		
	STAssertTrue([self assertEncodedObject:[NSNumber numberWithBool:NO] 
		isEqualToContentsOfFile:@"boolean_1.amf3"], @"Boolean data is not equal");
}

- (void)testNull
{
	STAssertTrue([self assertDataOfFile:@"null_0.amf3" 
		isEqualTo:[NSNull null]], @"Could not read null value");
}

- (void)testString
{
	NSString *str = @"hello";
	STAssertTrue([self assertDataOfFile:@"string_0.amf3" 
		isEqualTo:str], @"Strings do not match");
		
	STAssertTrue([self assertEncodedObject:str isEqualToContentsOfFile:@"string_0.amf3"], 
		@"String data is not equal");
		
	str = @"ᚠᛇᚻ";
	STAssertTrue([self assertDataOfFile:@"string_1.amf3" 
		isEqualTo:str], @"Strings do not match");
		
	STAssertTrue([self assertEncodedObject:str isEqualToContentsOfFile:@"string_1.amf3"], 
		@"String data is not equal");
}

- (void)testArray
{
	NSArray *arr = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:1], 
		[NSNumber numberWithInt:2], [NSNumber numberWithInt:3], nil];
	STAssertTrue([self assertDataOfFile:@"array_0.amf3" 
		isEqualTo:arr], @"Arrays do not match");

	STAssertTrue([self assertEncodedObject:arr isEqualToContentsOfFile:@"array_0.amf3"], 
		@"Array data is not equal");
}

- (void)testDictionary
{
	NSDictionary *dict = [NSDictionary dictionaryWithObject:@"eggs" forKey:@"spam"];
	STAssertTrue([self assertDataOfFile:@"dictionary_0.amf3" 
		isEqualTo:dict], @"Dictionaries do not match");
		
	STAssertTrue([self assertEncodedObject:dict isEqualToContentsOfFile:@"dictionary_0.amf3"], 
		@"Dictionary data is not equal");
	
	dict = [NSDictionary dictionaryWithObjectsAndKeys:@"a", @"a", @"b", @"b", @"c", @"c", 
		@"d", @"d", nil];
	STAssertTrue([self assertDataOfFile:@"dictionary_1.amf3" 
		isEqualTo:dict], @"Dictionaries do not match");
		
	STAssertTrue([self assertEncodedObject:dict isEqualToContentsOfFile:@"dictionary_1.amf3"], 
		@"Dictionary data is not equal");
}

- (void)testRegisteredTypedObject
{
	Spam *spam = [[Spam alloc] init];
	spam.baz = @"hello";
	
	AMFUnarchiver *unarchiver = [self unarchiverForPath:@"typedobject_0.amf3"];
	[unarchiver setClass:[Spam class] forClassName:@"org.pyamf.spam"];
	id result = [unarchiver decodeObject];
	STAssertTrue([spam isEqual:result], @"Registered typed object test failed.");
	
	AMFArchiver *archiver = [[AMFArchiver alloc] initForWritingWithMutableData:[NSMutableData data] 
		encoding:kAMF3Version];
	[archiver setClassName:@"org.pyamf.spam" forClass:[Spam class]];
	[archiver encodeRootObject:spam];
	NSData *data = [NSData dataWithContentsOfFile:[self fullPathForTestFile:@"typedobject_0.amf3" 
		version:nil]];
	STAssertTrue([data isEqual:[archiver archiverData]], @"Registered typed object data is not equal");
	[archiver release];
	
	[spam release];
}

- (void)testFlexDataTypes
{
	FlexArrayCollection *coll = [[FlexArrayCollection alloc] initWithSource:
		[NSArray arrayWithObjects:
			@"bla", 
			[[FlexArrayCollection alloc] initWithSource:
				[NSArray arrayWithObjects:
					[NSNumber numberWithInt:1], 
					[NSNumber numberWithInt:2], 
					[NSNumber numberWithInt:3],
					nil]], nil]];
	STAssertTrue([self assertDataOfFile:@"flexdatatypes_0.amf3" isEqualTo:coll], 
		@"ArrayCollections do not match.");
	STAssertTrue([self assertEncodedObject:coll isEqualToContentsOfFile:@"flexdatatypes_0.amf3"], 
		@"ArrayCollection data is not equal");
	[coll release];
}

- (void)testKeyedNonKeyedIntegrity
{
	WrongSerializedCustomObject *obj = [[WrongSerializedCustomObject alloc] init];
	STAssertThrows([AMFArchiver archivedDataWithRootObject:obj encoding:kAMF3Version], 
		@"Keyed/non-keyed archiving was mixed without an exception");
}

- (void)testExternalizable
{
	PlainStringEncoder *obj = [[PlainStringEncoder alloc] init];
	STAssertTrue([self assertDataOfFile:@"plainstringexternalizable_0.amf3" isEqualTo:obj], 
		@"Could not deserialize utf bytes");
	STAssertTrue([self assertEncodedObject:obj isEqualToContentsOfFile:@"plainstringexternalizable_0.amf3"], 
		@"Could not serialize utf bytes properly");
}

@end