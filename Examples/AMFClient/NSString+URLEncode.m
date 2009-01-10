//
//  NSString+URLEncode.m
//  CocoaAMF
//
//  Created by Marc Bauer on 30.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "NSString+URLEncode.h"


@implementation NSString (URLEncode)

- (NSString *)URLEncodedString
{
	NSArray *specialChars = [NSArray arrayWithObjects:@";", @"/", @"?", @":", @"@", @"&", @"=", 
		@"+", @"$", @",", @"[", @"]", @"#", @"!", @"'", @"(", @")", @"*", @" ", @"{", @"}", @"\"", 
		nil];
	NSArray *escapedChars = [NSArray arrayWithObjects:@"%3B", @"%2F", @"%3F", @"%3A", @"%40", 
		@"%26", @"%3D", @"%2B", @"%24", @"%2C", @"%5B", @"%5D", @"%23", @"%21", @"%27", @"%28",
		@"%29", @"%2A", @"%20", @"%7B", @"%7D", @"%22", nil];

	NSMutableString *escapedString = [NSMutableString stringWithString:self];
	for (int i = 0; i < [specialChars count]; i++)
	{
		NSString *specialChar = [specialChars objectAtIndex:i];
		NSString *escapedChar = [escapedChars objectAtIndex:i];
		[escapedString replaceOccurrencesOfString:specialChar withString:escapedChar 
			options:NSLiteralSearch range:(NSRange){0, [escapedString length]}];
	}
	return escapedString;
}

@end