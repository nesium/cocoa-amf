//
//  main.m
//  CocoaAMF
//
//  Created by Marc Bauer on 11.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AMFRemotingCall.h"


@interface RemotingCaller : NSObject <AMFRemotingCallDelegate>
{
	AMFRemotingCall *m_remotingCall;
}
- (void)call;
@end

@implementation RemotingCaller

- (id)init
{
	if (self = [super init])
	{
		m_remotingCall = [[AMFRemotingCall alloc] 
			initWithURL:[NSURL URLWithString:@"http://www.nesium.com/amfdemo/gateway.php"] 
			service:@"ExampleService" method:@"add" 
			arguments:[NSArray arrayWithObjects:[NSNumber numberWithInt:2], 
				[NSNumber numberWithInt:3], nil]];
		m_remotingCall.delegate = self;
		
		// you may also try the following methods with an empty array as arguments
		// - hello
		// - returnArray
		// - returnArrayCollection
	}
	return self;
}

- (void)call
{
	[m_remotingCall start];
}

- (void)remotingCallDidFinishLoading:(AMFRemotingCall *)remotingCall 
	receivedObject:(NSObject *)object
{
	NSLog(@"remoting call was successful. received data: %@", object);
	CFRunLoopStop([[NSRunLoop currentRunLoop] getCFRunLoop]);
}

- (void)remotingCall:(AMFRemotingCall *)remotingCall didFailWithError:(NSError *)error
{
	NSLog(@"remoting call failed with error %@", error);
	CFRunLoopStop([[NSRunLoop currentRunLoop] getCFRunLoop]);	
}

@end



int main (int argc, const char * argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	RemotingCaller *caller = [[RemotingCaller alloc] init];
	[caller call];
	
	CFRunLoopRun();
	[pool release];
	return 0;
}
