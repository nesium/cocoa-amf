//
//  AMF0Test.m
//  CocoaAMF
//
//  Created by Marc Bauer on 09.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "AMF0Test.h"


@implementation AMF0Test

- (void)testReadNumber
{
	STAssertTrue([self assertDataOfFile:@"read_number_0.amf0" 
		isEqualTo:[NSNumber numberWithInt:0]], @"Numbers do not match");
	STAssertTrue([self assertDataOfFile:@"read_number_1.amf0" 
		isEqualTo:[NSNumber numberWithDouble:0.2]], @"Numbers do not match");
	STAssertTrue([self assertDataOfFile:@"read_number_2.amf0" 
		isEqualTo:[NSNumber numberWithInt:1]], @"Numbers do not match");
	STAssertTrue([self assertDataOfFile:@"read_number_3.amf0" 
		isEqualTo:[NSNumber numberWithInt:42]], @"Numbers do not match");
	STAssertTrue([self assertDataOfFile:@"read_number_4.amf0" 
		isEqualTo:[NSNumber numberWithInt:-123]], @"Numbers do not match");
	STAssertTrue([self assertDataOfFile:@"read_number_5.amf0" 
		isEqualTo:[NSNumber numberWithDouble:1.23456789]], @"Numbers do not match");
}

- (void)testReadBoolean
{
	STAssertTrue([self assertDataOfFile:@"read_boolean_0.amf0" 
		isEqualTo:[NSNumber numberWithBool:YES]], @"Booleans do not match");
	STAssertTrue([self assertDataOfFile:@"read_boolean_1.amf0" 
		isEqualTo:[NSNumber numberWithBool:NO]], @"Booleans do not match");
}

- (void)testReadString
{
	STAssertTrue([self assertDataOfFile:@"read_string_0.amf0" 
		isEqualTo:@""], @"Strings do not match");
	STAssertTrue([self assertDataOfFile:@"read_string_1.amf0" 
		isEqualTo:@"hello"], @"Strings do not match");
	STAssertTrue([self assertDataOfFile:@"read_string_2.amf0" 
		isEqualTo:@"ᚠᛇᚻ"], @"Strings do not match");
}

- (void)testReadNull
{
	STAssertTrue([self assertDataOfFile:@"read_null_0.amf0" 
		isEqualTo:[NSNull null]], @"Could not read null value");
}

- (void)testReadUndefined
{
	STAssertTrue([self assertDataOfFile:@"read_undefined_0.amf0" 
		isEqualTo:[NSNull null]], @"Could not read undefined value");
}

- (void)testReadArray
{
	STAssertTrue([self assertDataOfFile:@"read_array_0.amf0" 
		isEqualTo:[NSArray array]], @"Arrays do not match");
		
	NSArray *arr = [NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], 
		[NSNumber numberWithInt:3], nil];
	STAssertTrue([self assertDataOfFile:@"read_array_1.amf0" 
		isEqualTo:arr], @"Arrays do not match");
	
	arr = [NSArray arrayWithObject:[NSArray arrayWithObject:[NSNumber numberWithDouble:1.0]]];
	STAssertTrue([self assertDataOfFile:@"read_array_2.amf0" 
		isEqualTo:arr], 
		@"Arrays do not match");
		
	arr = [NSArray arrayWithObject:[NSArray arrayWithObjects:@"test", @"test", @"test", @"test", nil]];
	STAssertTrue([self assertDataOfFile:@"read_array_3.amf0" 
		isEqualTo:arr], @"Arrays do not match");

	ASObject *dict = [ASObject asObjectWithDictionary:[NSDictionary 
		dictionaryWithObjectsAndKeys:@"spam", @"a", @"eggs", @"b"]];
	arr = [NSArray arrayWithObject:[NSArray arrayWithObjects:dict, dict, nil]];
	STAssertTrue([self assertDataOfFile:@"read_array_4.amf0" 
		isEqualTo:arr], @"Arrays do not match");
		
	STAssertTrue([self assertEncodedObject:arr isEqualToContentsOfFile:@"read_array_4.amf0"], 
		@"Array data is not equal");
}

- (void)testReadObject
{
	STAssertTrue([self assertDataOfFile:@"read_object_0.amf0" 
		isEqualTo:[ASObject asObjectWithDictionary:
			[NSDictionary dictionaryWithObject:@"a" forKey:@"a"]]], @"Objects do not match");
}

- (void)testReadDictionary
{
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:1], @"a", 
		[NSNumber numberWithInt:2], @"b", 
		[NSNumber numberWithInt:3], @"c", nil];
	STAssertTrue([self assertDataOfFile:@"read_dictionary_0.amf0" 
		isEqualTo:dict], @"Dictionaries do not match");	
}

- (void)testReadDate
{
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:1042326000];
	STAssertTrue([self assertDataOfFile:@"read_date_0.amf0" 
		isEqualTo:date], @"Dates do not match");
}


@end