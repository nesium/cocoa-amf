//
//  Controller.m
//  CocoaAMF
//
//  Created by Marc Bauer on 07.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "Controller.h"


@implementation Controller

- (void)awakeFromNib
{
//	NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] 
//		pathForResource:@"DemoApplication" ofType:@"swf"]];
//	unsigned char *ptr = calloc([data length], sizeof(unsigned char));
//	[data getBytes:ptr];
//	
//	int i = 0;
//	for (; i < [data length]; i++)
//	{
//		printf("-> %c\n", *str);
//		str++;
//	}	
	
	//unsigned char str1[5] = "hello";
	//unsigned char *ptr = str1;
//	unsigned char *str = calloc(10, sizeof(unsigned char));
//	unsigned char byte = *ptr;
//	str[0] = byte;
//	ptr++;
//	byte = *ptr;
//	str[1] = byte;
//	ptr++;
//	byte = *ptr;
//	str[2] = byte;
//	printf("test: %s", str);

	//char str[] = "\x06\x82\x45\xe1\x83\xa6\xe1\x83\x9b\xe1\x83\x94\xe1\x83\xa0\xe1\x83\x97\xe1\x83\xa1\xe1\x83\x98\x20\xe1\x83\xa8\xe1\x83\x94\xe1\x83\x9b\xe1\x83\x95\xe1\x83\x94\xe1\x83\x93\xe1\x83\xa0\xe1\x83\x94\x2c\x20\xe1\x83\x9c\xe1\x83\xa3\xe1\x83\x97\xe1\x83\xa3\x20\xe1\x83\x99\xe1\x83\x95\xe1\x83\x9a\xe1\x83\x90\x20\xe1\x83\x93\xe1\x83\x90\xe1\x83\x9b\xe1\x83\xae\xe1\x83\xa1\xe1\x83\x9c\xe1\x83\x90\xe1\x83\xa1\x20\xe1\x83\xa1\xe1\x83\x9d\xe1\x83\xa4\xe1\x83\x9a\xe1\x83\x98\xe1\x83\xa1\xe1\x83\x90\x20\xe1\x83\xa8\xe1\x83\xa0\xe1\x83\x9d\xe1\x83\x9b\xe1\x83\x90\xe1\x83\xa1\xe1\x83\x90\x2c\x20\xe1\x83\xaa\xe1\x83\x94\xe1\x83\xaa\xe1\x83\xae\xe1\x83\x9a\xe1\x83\xa1";
	//char str[] = "\n\x0b\x1dorg.pyamf.spam\007baz\x06\x0bhello\x01";
	//char str[] = "\x09\x09\x01\x04\x00\x04\x01\x04\x02\x04\x03";
//	char str[] = "@\x93JEm\\\xfa\xad";
//	
//	NSData *data = [NSData dataWithBytes:&str length:strlen(str)];
//	NSLog(@"length: %d", strlen(str));
//	AMF3Deserializer *deserializer = [[AMF3Deserializer alloc] initWithData:data];
//	//[deserializer deserialize];
//	NSLog(@"result: %@", [deserializer deserialize]);
//	
//	char bla = 'a';
//	NSValue *test = [NSValue valueWithBytes:&bla objCType:@encode(char)];
//	NSLog(@"%s", [test objCType]);
//	NSLog(@"%s", [[NSNumber numberWithInt:1] objCType]);
	
	//[deserializer release];
	
	AMFInputStream *inStream = [[AMFInputStream alloc] initWithData:
		[NSData dataWithContentsOfFile:
		[@"~/Library/Preferences/Macromedia/Flash Player/#SharedObjects/KS44HXBT/localhost/Projekte/Nsm/Apps/RemotingTest/bin/remotingtest.swf/c#/om.nesium.remoting.UnitTest.sol"
			stringByExpandingTildeInPath]]];
	SODeserializer *deserializer = [[SODeserializer alloc] initWithStream:inStream];
	[deserializer deserialize];
}

@end