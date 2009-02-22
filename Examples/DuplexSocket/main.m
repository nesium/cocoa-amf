//
//  main.m
//  CocoaAMF
//
//  Created by Marc Bauer on 20.02.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AMFDuplexGateway.h"

@interface TestService : NSObject
{
}
@end

@implementation TestService

- (NSArray *)sayHello:(NSString *)to
{
	NSLog(@"Hello %@", to);
	return [NSArray arrayWithObjects:@"1", @"2", @"3", nil];
}

@end


int main (int argc, const char * argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	
	NSError *error;
	uint16_t port = 8888;
	
	AMFDuplexGateway *gateway = [[AMFDuplexGateway alloc] init];
	[gateway registerService:[[[TestService alloc] init] autorelease] withName:@"TestService"];
	
	if (![gateway startOnPort:port error:&error])
	{
		NSLog(@"Could not start server on port %d. Reason: %@", port, error);
	}
	else
	{
		[runLoop run];
	}
	[gateway release];
	[pool drain];
	[pool release];
	return 0;
}