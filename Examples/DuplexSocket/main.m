//
//  main.m
//  CocoaAMF
//
//  Created by Marc Bauer on 20.02.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AMFDuplexGateway.h"

@interface ServerService : NSObject
{
}
@end

@implementation ServerService

- (NSArray *)sayHello:(NSString *)to
{
	NSLog(@"[server] hello %@", to);
	return [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", nil];
}

- (void)sayHello_complete:(id)sender
{
	NSLog(@"[server] Say hello complete: %@", [sender result]);
}

- (void)gateway:(AMFDuplexGateway *)gateway remoteGatewayDidConnect:(AMFRemoteGateway *)remote
{
	AMFInvocationResult *result = [remote invokeRemoteService:@"ClientService" methodName:@"sayHello" 
		arguments:@"Wuff", nil];
	result.target = self;
	result.action = @selector(sayHello_complete:);
}

- (void)gateway:(AMFDuplexGateway *)gateway remoteGatewayDidDisconnect:(AMFRemoteGateway *)remote
{
	NSLog(@"did disconnect");
}
@end


@interface ClientService : NSObject
{
}
@end

@implementation ClientService

- (NSString *)sayHello:(NSArray *)array
{
	NSLog(@"[client] hello %@", [array objectAtIndex:1]);
	return @"A return value";
}

- (void)sayHello_complete:(id)sender
{
	NSLog(@"[client] Say hello complete: %@", [sender result]);
}

- (void)gateway:(AMFDuplexGateway *)gateway remoteGatewayDidConnect:(AMFRemoteGateway *)remote
{
	AMFInvocationResult *result = [remote invokeRemoteService:@"ServerService" methodName:@"sayHello" 
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
	
	AMFDuplexGateway *serverGateway = [[AMFDuplexGateway alloc] init];
	ServerService *serverService = [[ServerService alloc] init];
	[serverGateway registerService:serverService withName:@"ServerService"];
	serverGateway.delegate = serverService;
	
	if (![serverGateway startOnPort:port error:&error])
	{
		NSLog(@"Could not start server on port %d. Reason: %@", port, error);
		return -1;
	}
	
	AMFDuplexGateway *clientGateway = [[AMFDuplexGateway alloc] init];
	ClientService *clientService = [[ClientService alloc] init];
	[clientGateway registerService:clientService withName:@"ClientService"];
	clientGateway.delegate = clientService;
	[clientGateway connectToRemote:@"localhost" port:port error:&error];
	
	[runLoop run];
	[serverGateway release];
	[pool drain];
	[pool release];
	return 0;
}