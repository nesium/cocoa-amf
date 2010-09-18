//
//  AMF3Test.m
//  CocoaAMF
//
//  Created by Marc Bauer on 20.02.09.
//  Copyright 2009 Fork Unstable Media GmbH. All rights reserved.
//

#import "AMF3Test.h"

@implementation WrongSerializedCustomObject

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:@"foo"];
	[coder encodeObject:@"foo" forKey:@"bar"];
}
@end


@implementation PlainStringEncoder

- (id)init{
	if (self = [super init]){
		m_string = [@"Hello World" retain];
	}
	return self;
}

- (void)dealloc{
	[m_string release];
	[super dealloc];
}

- (BOOL)isEqual:(id)obj{
	if (![obj isMemberOfClass:[self class]]){
		return NO;
	}
	return [((PlainStringEncoder *)obj)->m_string isEqual:m_string];
}

- (id)initWithCoder:(NSCoder *)coder{
	if (self = [super init]){
		m_string = [[(AMFUnarchiver *)coder decodeUTFBytes:11] retain];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder{
	[(AMFArchiver *)coder encodeUTFBytes:m_string];
}
@end


@implementation ExternalizableDataEncoder

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:@"a"];
	NSMutableData *data = [NSMutableData data];
	uint16_t i = 0xffff;
	[data appendBytes:&i length:sizeof(uint16_t)];
	[coder encodeDataObject:data];
	[coder encodeObject:@"b"];
}

@end


@implementation AnotherExternalizableObject
@synthesize child, name;

- (void)dealloc{
	[child release];
	[name release];
	[super dealloc];
}

- (NSString *)description{
	return [NSString stringWithFormat:@"<%@ = 0x%08x> name: %@, child:\n-> %@", [self className], 
		(long)self, name, child];
}

- (id)initWithCoder:(NSCoder *)aCoder{
	if (self = [super init]){
		child = [[aCoder decodeObject] retain];
		name = [[aCoder decodeObject] retain];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aDecoder{
	[aDecoder encodeObject:child];
	[aDecoder encodeObject:name];
}

- (BOOL)isEqual:(id)anObject{
	if (![anObject isMemberOfClass:[self class]]){
		return NO;
	}
	AnotherExternalizableObject *other = (AnotherExternalizableObject *)anObject;
	return ((name == nil && other.name == nil) || 
				(name == nil && (id)other.name == [NSNull null]) || 
				((id)name == [NSNull null] && other.name == nil) || 
				((id)name == [NSNull null] && (id)other.name == [NSNull null]) || 
				[name isEqualToString:other.name]) && 
			((child == nil && other.child == nil) || 
				(child == nil && (id)other.child == [NSNull null]) || 
				((id)child == [NSNull null] && other.child == nil) || 
				((id)child == [NSNull null] && (id)other.child == [NSNull null]) || 
				[child isEqual:other.child]);
}
@end






@implementation AMF3Test

- (void)testNumber{
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

- (void)testBoolean{
	STAssertTrue([self assertDataOfFile:@"boolean_0.amf3" 
		isEqualTo:[NSNumber numberWithBool:YES]], @"Booleans do not match");
		
	STAssertTrue([self assertEncodedObject:[NSNumber numberWithBool:YES] 
		isEqualToContentsOfFile:@"boolean_0.amf3"], @"Boolean data is not equal");
		
	STAssertTrue([self assertDataOfFile:@"boolean_1.amf3" 
		isEqualTo:[NSNumber numberWithBool:NO]], @"Booleans do not match");
		
	STAssertTrue([self assertEncodedObject:[NSNumber numberWithBool:NO] 
		isEqualToContentsOfFile:@"boolean_1.amf3"], @"Boolean data is not equal");
}

- (void)testNull{
	STAssertTrue([self assertDataOfFile:@"null_0.amf3" 
		isEqualTo:nil], @"Could not read null value");
		
	STAssertTrue([self assertEncodedObject:[NSNull null] isEqualToContentsOfFile:@"null_0.amf3"], 
		@"Null data is not equal");
		
	STAssertTrue([self assertEncodedObject:nil isEqualToContentsOfFile:@"null_0.amf3"], 
		@"Nil data is not equal");
}

- (void)testString{
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
	
	STAssertTrue([self assertDataOfFile:@"string_2.amf3" isEqualTo:@"Hello World Åäö!"], 
		@"Could not decode Latin1 string");
}

- (void)testArray{
	NSArray *arr = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:1], 
		[NSNumber numberWithInt:2], [NSNumber numberWithInt:3], nil];
	STAssertTrue([self assertDataOfFile:@"array_0.amf3" 
		isEqualTo:arr], @"Arrays do not match");

	STAssertTrue([self assertEncodedObject:arr isEqualToContentsOfFile:@"array_0.amf3"], 
		@"Array data is not equal");
}

- (void)testDictionary{
	NSDictionary *dict = [NSDictionary dictionaryWithObject:@"eggs" forKey:@"spam"];
	STAssertTrue([self assertDataOfFile:@"dictionary_0.amf3" 
		isEqualTo:dict], @"Dictionaries do not match");
		
	STAssertTrue([self assertEncodedObject:dict isEqualToContentsOfFile:@"dictionary_0.amf3"], 
		@"Dictionary data is not equal");

// this test is flawed, since dictionary entries are unordered	
//	dict = [NSDictionary dictionaryWithObjectsAndKeys:@"a", @"a", @"b", @"b", @"c", @"c", 
//		@"d", @"d", nil];
//	STAssertTrue([self assertDataOfFile:@"dictionary_1.amf3" 
//		isEqualTo:dict], @"Dictionaries do not match");
//		
//	STAssertTrue([self assertEncodedObject:dict isEqualToContentsOfFile:@"dictionary_1.amf3"], 
//		@"Dictionary data is not equal");
}

- (void)testRegisteredTypedObject{
	Spam *spam = [[Spam alloc] init];
	spam.baz = @"hello";
	
	AMFUnarchiver *unarchiver = [self unarchiverForPath:@"typedobject_0.amf3"];
	[unarchiver setClass:[Spam class] forClassName:@"org.pyamf.spam"];
	id result = [unarchiver decodeObject];
	STAssertTrue([spam isEqual:result], @"Registered typed object test failed.");
	
	AMFArchiver *archiver = [[AMFArchiver alloc] initForWritingWithMutableData:[NSMutableData data] 
		encoding:kAMF3Encoding];
	[archiver setClassName:@"org.pyamf.spam" forClass:[Spam class]];
	[archiver encodeRootObject:spam];
	NSData *data = [NSData dataWithContentsOfFile:[self fullPathForTestFile:@"typedobject_0.amf3" 
		version:nil]];
	STAssertTrue([data isEqual:[archiver archiverData]], @"Registered typed object data is not equal");
	[archiver release];
	
	[spam release];
}

- (void)testFlexDataTypes{
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

- (void)testOptions{
	NSArray *arr = [NSArray arrayWithObjects:
		@"bla",
		[NSArray arrayWithObjects:
			[NSNumber numberWithInt:1], 
			[NSNumber numberWithInt:2], 
			[NSNumber numberWithInt:3],
			nil], nil];
	[AMFUnarchiver setOptions:AMFUnarchiverUnpackArrayCollection];
	[AMFArchiver setOptions:AMFArchiverPackArrayOption];
	STAssertTrue([self assertDataOfFile:@"flexdatatypes_0.amf3" isEqualTo:arr], 
		@"Arrays do not match.");
	STAssertTrue([self assertEncodedObject:arr isEqualToContentsOfFile:@"flexdatatypes_0.amf3"], 
		@"Array data is not equal");
	[AMFUnarchiver setOptions:0];
	[AMFArchiver setOptions:0];
}

- (void)testKeyedNonKeyedIntegrity{
	WrongSerializedCustomObject *obj = [[WrongSerializedCustomObject alloc] init];
	STAssertThrows([AMFArchiver archivedDataWithRootObject:obj encoding:kAMF3Encoding], 
		@"Keyed/non-keyed archiving was mixed without an exception");
	[obj release];
}

- (void)testExternalizable{
	PlainStringEncoder *obj = [[PlainStringEncoder alloc] init];
	STAssertTrue([self assertDataOfFile:@"plainstringexternalizable_0.amf3" isEqualTo:obj], 
		@"Could not deserialize utf bytes");
	STAssertTrue([self assertEncodedObject:obj isEqualToContentsOfFile:@"plainstringexternalizable_0.amf3"], 
		@"Could not serialize utf bytes properly");
	[obj release];
}

- (void)testExternalizableData{
	ExternalizableDataEncoder *obj = [[ExternalizableDataEncoder alloc] init];
	STAssertTrue([self assertEncodedObject:obj isEqualToContentsOfFile:@"externalizabledata.amf3"], 
		@"Could not serialize externalizable data properly");
	[obj release];
}

- (void)testNestedExternalizable{
	AnotherExternalizableObject *subChild = [[AnotherExternalizableObject alloc] init];
	subChild.name = @"subChild";
	AnotherExternalizableObject *child = [[AnotherExternalizableObject alloc] init];
	child.name = @"Child";
	child.child = subChild;
	AnotherExternalizableObject *parent = [[AnotherExternalizableObject alloc] init];
	parent.name = @"Parent";
	parent.child = child;
	
	NSMutableData *data = [[NSMutableData alloc] init];
	AMFArchiver *archiver = [[AMFArchiver alloc] initForWritingWithMutableData:data 
		encoding:kAMF3Encoding];
	[archiver setClassName:@"AnotherExternalizableObject" 
		forClass:[AnotherExternalizableObject class]];
	[archiver encodeRootObject:parent];
	[archiver release];
	
	AMFUnarchiver *unarchiver = [[AMFUnarchiver alloc] initForReadingWithData:data 
		encoding:kAMF3Encoding];
	[unarchiver setClass:[AnotherExternalizableObject class] 
		forClassName:@"AnotherExternalizableObject"];
	AnotherExternalizableObject *decodedParent = 
		(AnotherExternalizableObject *)[unarchiver decodeObject];
	[unarchiver release];
	[data release];
		
	STAssertTrue([parent isEqual:decodedParent], @"Original & decoded objects should be equal");
	[subChild release];
	[child release];
	[parent release];
}

- (void)testByteArray{
	NSMutableData *data = [NSMutableData data];
	uint8_t byte1 = 0x0;
	uint8_t byte2 = 0x1;
	uint8_t byte3 = 0x2;
	[data appendBytes:&byte1 length:sizeof(uint8_t)];
	[data appendBytes:&byte2 length:sizeof(uint8_t)];
	[data appendBytes:&byte3 length:sizeof(uint8_t)];
	STAssertTrue([self assertDataOfFile:@"bytearray_0.amf3" isEqualTo:data], 
		@"Could not deserialize ByteArray properly");
	STAssertTrue([self assertEncodedObject:data isEqualToContentsOfFile:@"bytearray_0.amf3"], 
		@"Could not serialize ByteArray properly");
}
@end