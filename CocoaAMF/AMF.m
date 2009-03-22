//
//  AMF.m
//  CocoaAMF
//
//  Created by Marc Bauer on 23.03.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "AMF.h"

NSString * NSStringFromAMF0Type(AMF0Type type)
{
	switch (type)
	{
		case kAMF0NumberType:
			return @"AMF0NumberType";
		case kAMF0BooleanType:
			return @"AMF0BooleanType";
		case kAMF0StringType:
			return @"AMF0StringType";
		case kAMF0ObjectType:
			return @"AMF0ObjectType";
		case kAMF0MovieClipType:
			return @"AMF0MovieClipType";
		case kAMF0NullType:
			return @"AMF0NullType";
		case kAMF0UndefinedType:
			return @"AMF0UndefinedType";
		case kAMF0ReferenceType:
			return @"AMF0ReferenceType";
		case kAMF0ECMAArrayType:
			return @"AMF0ECMAArrayType";
		case kAMF0ObjectEndType:
			return @"AMF0ObjectEndType";
		case kAMF0StrictArrayType:
			return @"AMF0StrictArrayType";
		case kAMF0DateType:
			return @"AMF0DateType";
		case kAMF0LongStringType:
			return @"AMF0LongStringType";
		case kAMF0UnsupportedType:
			return @"AMF0UnsupportedType";
		case kAMF0RecordsetType:
			return @"AMF0RecordsetType";
		case kAMF0XMLObjectType:
			return @"AMF0XMLObjectType";
		case kAMF0TypedObjectType:
			return @"AMF0TypedObjectType";
		case kAMF0AVMPlusObjectType:
			return @"AMF0AVMPlusObjectType";
	}
	return @"AMF0 Unknown type!";
}

NSString * NSStringFromAMF3Type(AMF3Type type)
{
	switch (type)
	{
		case kAMF3UndefinedType:
			return @"AMF3UndefinedType";
		case kAMF3NullType:
			return @"AMF3NullType";
		case kAMF3FalseType:
			return @"AMF3FalseType";
		case kAMF3TrueType:
			return @"AMF3TrueType";
		case kAMF3IntegerType:
			return @"AMF3IntegerType";
		case kAMF3DoubleType:
			return @"AMF3DoubleType";
		case kAMF3StringType:
			return @"AMF3StringType";
		case kAMF3XMLDocType:
			return @"AMF3XMLDocType";
		case kAMF3DateType:
			return @"AMF3DateType";
		case kAMF3ArrayType:
			return @"AMF3ArrayType";
		case kAMF3ObjectType:
			return @"AMF3ObjectType";
		case kAMF3XMLType:
			return @"AMF3XMLType";
		case kAMF3ByteArrayType:
			return @"AMF3ByteArrayType";
	}
	return @"AMF3 Unknown type!";
}