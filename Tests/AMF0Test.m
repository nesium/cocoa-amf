//
//  AMF0Test.m
//  CocoaAMF
//
//  Created by Marc Bauer on 09.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "AMF0Test.h"

@implementation AMF0Test

- (void)testNumber{
	NSNumber *num = [NSNumber numberWithInt:0];
	XCTAssertTrue([self assertDataOfFile:@"number_0.amf0" 
		isEqualTo:num], @"Numbers do not match");
	
	XCTAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_0.amf0"], 
		@"Number data is not equal");
	
	num = [NSNumber numberWithDouble:0.2];
	XCTAssertTrue([self assertDataOfFile:@"number_1.amf0" 
		isEqualTo:num], @"Numbers do not match");
		
	XCTAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_1.amf0"], 
		@"Number data is not equal");
	
	num = [NSNumber numberWithInt:1];
	XCTAssertTrue([self assertDataOfFile:@"number_2.amf0" 
		isEqualTo:num], @"Numbers do not match");
		
	XCTAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_2.amf0"], 
		@"Number data is not equal");
	
	num = [NSNumber numberWithInt:42];
	XCTAssertTrue([self assertDataOfFile:@"number_3.amf0" 
		isEqualTo:num], @"Numbers do not match");
		
	XCTAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_3.amf0"], 
		@"Number data is not equal");
	
	num = [NSNumber numberWithInt:-123];
	XCTAssertTrue([self assertDataOfFile:@"number_4.amf0" 
		isEqualTo:num], @"Numbers do not match");
		
	XCTAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_4.amf0"], 
		@"Number data is not equal");
		
	num = [NSNumber numberWithDouble:1.23456789];
	XCTAssertTrue([self assertDataOfFile:@"number_5.amf0" 
		isEqualTo:num], @"Numbers do not match");
		
	XCTAssertTrue([self assertEncodedObject:num isEqualToContentsOfFile:@"number_5.amf0"], 
		@"Number data is not equal");
}

- (void)testBoolean{
	XCTAssertTrue([self assertDataOfFile:@"boolean_0.amf0" 
		isEqualTo:[NSNumber numberWithBool:YES]], @"Booleans do not match");
		
	XCTAssertTrue([self assertEncodedObject:[NSNumber numberWithBool:YES] 
		isEqualToContentsOfFile:@"boolean_0.amf0"], @"Boolean data is not equal");
		
	XCTAssertTrue([self assertDataOfFile:@"boolean_1.amf0" 
		isEqualTo:[NSNumber numberWithBool:NO]], @"Booleans do not match");
		
	XCTAssertTrue([self assertEncodedObject:[NSNumber numberWithBool:NO] 
		isEqualToContentsOfFile:@"boolean_1.amf0"], @"Boolean data is not equal");
}

- (void)testString{
	NSString *str = @"";
	XCTAssertTrue([self assertDataOfFile:@"string_0.amf0" 
		isEqualTo:str], @"Strings do not match");
		
	XCTAssertTrue([self assertEncodedObject:str isEqualToContentsOfFile:@"string_0.amf0"], 
		@"String data is not equal");
	
	str = @"hello";
	XCTAssertTrue([self assertDataOfFile:@"string_1.amf0" 
		isEqualTo:str], @"Strings do not match");
	
	XCTAssertTrue([self assertEncodedObject:str isEqualToContentsOfFile:@"string_1.amf0"], 
		@"String data is not equal");
	
	str = @"ᚠᛇᚻ";
	XCTAssertTrue([self assertDataOfFile:@"string_2.amf0" 
		isEqualTo:str], @"Strings do not match");
		
	XCTAssertTrue([self assertEncodedObject:str isEqualToContentsOfFile:@"string_2.amf0"], 
		@"String data is not equal");
}

- (void)testNull{
	XCTAssertTrue([self assertDataOfFile:@"null_0.amf0" 
		isEqualTo:nil], @"Could not read null value");
		
	XCTAssertTrue([self assertEncodedObject:[NSNull null] isEqualToContentsOfFile:@"null_0.amf0"], 
		@"Null data is not equal");
		
	XCTAssertTrue([self assertEncodedObject:nil isEqualToContentsOfFile:@"null_0.amf0"], 
		@"Nil data is not equal");
}

- (void)testUndefined{
	XCTAssertTrue([self assertDataOfFile:@"undefined_0.amf0" 
		isEqualTo:nil], @"Could not read undefined value");
}

- (void)testArray{
	NSArray *arr = [NSArray array];
	XCTAssertTrue([self assertDataOfFile:@"array_0.amf0" 
		isEqualTo:arr], @"Arrays do not match");
		
	XCTAssertTrue([self assertEncodedObject:arr isEqualToContentsOfFile:@"array_0.amf0"], 
		@"Array data is not equal");
		
	arr = [NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], 
		[NSNumber numberWithInt:3], nil];
	XCTAssertTrue([self assertDataOfFile:@"array_1.amf0" 
		isEqualTo:arr], @"Arrays do not match");

	XCTAssertTrue([self assertEncodedObject:arr isEqualToContentsOfFile:@"array_1.amf0"], 
		@"Array data is not equal");
	
	arr = [NSArray arrayWithObject:[NSArray arrayWithObject:[NSNumber numberWithDouble:1.0]]];
	XCTAssertTrue([self assertDataOfFile:@"array_2.amf0" 
		isEqualTo:arr], 
		@"Arrays do not match");
		
	XCTAssertTrue([self assertEncodedObject:arr isEqualToContentsOfFile:@"array_2.amf0"], 
		@"Array data is not equal");
		
	arr = [NSArray arrayWithObject:[NSArray arrayWithObjects:@"test", @"test", @"test", @"test", nil]];
	XCTAssertTrue([self assertDataOfFile:@"array_3.amf0" 
		isEqualTo:arr], @"Arrays do not match");
		
	XCTAssertTrue([self assertEncodedObject:arr isEqualToContentsOfFile:@"array_3.amf0"], 
		@"Array data is not equal");

	ASObject *dict = [ASObject asObjectWithDictionary:[NSDictionary 
		dictionaryWithObjectsAndKeys:@"spam", @"a", @"eggs", @"b", nil]];
	arr = [NSArray arrayWithObject:[NSArray arrayWithObjects:dict, dict, nil]];
	XCTAssertTrue([self assertDataOfFile:@"array_4.amf0" 
		isEqualTo:arr], @"Arrays do not match");
		
	XCTAssertTrue([self assertEncodedObject:arr isEqualToContentsOfFile:@"array_4.amf0"], 
		@"Array data is not equal");
}

- (void)testObject{
	ASObject *obj = [ASObject asObjectWithDictionary:
			[NSDictionary dictionaryWithObject:@"a" forKey:@"a"]];
	XCTAssertTrue([self assertDataOfFile:@"object_0.amf0" 
		isEqualTo:obj], @"Objects do not match");
		
	XCTAssertTrue([self assertEncodedObject:obj isEqualToContentsOfFile:@"object_0.amf0"], 
		@"Object data is not equal");
}

// this test is flawed, since dictionary entries are unordered
//- (void)testDictionary
//{
//	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//		[NSNumber numberWithInt:1], @"a", 
//		[NSNumber numberWithInt:2], @"b", 
//		[NSNumber numberWithInt:3], @"c", nil];
//	XCTAssertTrue([self assertDataOfFile:@"dictionary_0.amf0" 
//		isEqualTo:dict], @"Dictionaries do not match");
//		
//	XCTAssertTrue([self assertEncodedObject:dict isEqualToContentsOfFile:@"dictionary_0.amf0"], 
//		@"Dictionary data is not equal");
//}

- (void)testTypedObject{
	ASObject *obj = [ASObject asObjectWithDictionary:
		[NSDictionary dictionaryWithObject:@"hello" forKey:@"baz"]];
	obj.type = @"org.pyamf.spam";
	
	XCTAssertTrue([self assertDataOfFile:@"typedobject_0.amf0" 
		isEqualTo:obj], @"Typed objects do not match");
		
	XCTAssertTrue([self assertEncodedObject:obj isEqualToContentsOfFile:@"typedobject_0.amf0"], 
		@"Typed object data is not equal");
}

- (void)testRegisteredTypedObject{
	Spam *spam = [[Spam alloc] init];
	spam.baz = @"hello";
	
	AMFUnarchiver *unarchiver = [self unarchiverForPath:@"typedobject_0.amf0"];
	[unarchiver setClass:[Spam class] forClassName:@"org.pyamf.spam"];
	id result = [unarchiver decodeObject];
	XCTAssertTrue([spam isEqual:result], @"Registered typed object test failed.");
	
	AMFArchiver *archiver = [[AMFArchiver alloc] initForWritingWithMutableData:[NSMutableData data] 
		encoding:kAMF0Encoding];
	[archiver setClassName:@"org.pyamf.spam" forClass:[Spam class]];
	[archiver encodeRootObject:spam];
	NSData *data = [NSData dataWithContentsOfFile:[self fullPathForTestFile:@"typedobject_0.amf0" 
		version:nil]];
	XCTAssertTrue([data isEqual:[archiver archiverData]], @"Registered typed object data is not equal");
	[archiver release];
	
	[spam release];
}

- (void)testForceAMF3{
	ASObject *obj = [ASObject asObjectWithDictionary:
		[NSDictionary dictionaryWithObject:@"y" forKey:@"x"]];
	obj.type = @"spam.eggs";
	
	XCTAssertTrue([self assertDataOfFile:@"forceamf3_0.amf0" 
		isEqualTo:obj], @"forceAMF3 test failed");
}

- (void)testExternalizableObjectNotSupported{
	FlexArrayCollection *obj = [[FlexArrayCollection alloc] initWithSource:
		[NSArray arrayWithObjects:@"a", @"b", @"c", nil]];
	XCTAssertThrows([AMFArchiver archivedDataWithRootObject:obj encoding:kAMF0Encoding], 
		@"Encoding externalizable object did not throw");
}

//- (void)testReadDate
//{
//	NSDate *date = [NSDate dateWithTimeIntervalSince1970:1042326000];
//	XCTAssertTrue([self assertDataOfFile:@"read_date_0.amf0" 
//		isEqualTo:date], @"Dates do not match");
//}


@end
