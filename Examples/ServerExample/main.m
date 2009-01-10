#import <Foundation/Foundation.h>
#import "AMFGateway.h"
#import "DirectoryService.h"

int main (int argc, const char * argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	
	NSError *error;
	uint16_t port = 1234;
	
	AMFGateway *gateway = [[AMFGateway alloc] init];
	[gateway registerService:[[[DirectoryService alloc] init] autorelease]];
	
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