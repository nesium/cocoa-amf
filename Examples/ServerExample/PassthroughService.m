//
//  PassthroughService.m
//  CocoaAMF
//
//  Created by Marc Bauer on 24.03.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "PassthroughService.h"


@implementation PassthroughService

- (id)execute:(NSArray *)args
{
	if ([args count] < 1)
		return nil;
	id obj = [args objectAtIndex:0];
//	NSLog(@"received %@: %@", [obj className], obj);
	return obj;
}

@end