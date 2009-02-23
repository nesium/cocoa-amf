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
	return [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", nil];
}

- (void)sayHello_complete:(id)sender
{
	NSLog(@"Say hello complete: %@", [sender result]);
}

- (void)gateway:(AMFDuplexGateway *)gateway remoteGatewayDidConnect:(AMFRemoteGateway *)remote
{
	AMFInvocationResult *result = [remote invokeRemoteService:@"TestService" methodName:@"sayHello" 
		arguments:@"Wuff", nil];
	result.target = self;
	result.action = @selector(sayHello_complete:);
}

- (void)gateway:(AMFDuplexGateway *)gateway remoteGatewayDidDisconnect:(AMFRemoteGateway *)remote
{
	NSLog(@"did disconnect");
}

@end


int main (int argc, const char * argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	
	NSError *error;
	uint16_t port = 8888;
	
	AMFDuplexGateway *gateway = [[AMFDuplexGateway alloc] init];
	TestService *testService = [[TestService alloc] init];
	[gateway registerService:testService withName:@"TestService"];
	gateway.delegate = testService;
	
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