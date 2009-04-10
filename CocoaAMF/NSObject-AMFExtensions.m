//
//  NSObject-AMFExtensions.m
//  CocoaAMF
//
//  Created by Marc Bauer on 10.04.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "NSObject-AMFExtensions.h"


@implementation NSObject (AMFExtensions)

+ (NSString *)uuid
{
	CFUUIDRef uuidRef = CFUUIDCreate(NULL);
	CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
	CFRelease(uuidRef);
	return [(NSString *)uuidStringRef autorelease];
}

- (id)invokeMethodWithName:(NSString *)methodName arguments:(NSArray *)arguments 
	error:(NSError **)error
{
	return [self invokeMethodWithName:methodName arguments:arguments error:error 
		prependName:nil argument:nil];
}

- (id)invokeMethodWithName:(NSString *)methodName arguments:(NSArray *)arguments 
	error:(NSError **)error prependName:(NSString *)nameToPrepend 
	argument:(id)argumentToPrepend
{
	NSArray *methodNameComponents = [methodName componentsSeparatedByString:@"_"];
	
	if (nameToPrepend != nil)
	{
		if ([arguments count] < 1)
		{
			methodNameComponents = [NSArray arrayWithObject:[nameToPrepend stringByAppendingString:
				[methodName stringByReplacingCharactersInRange:(NSRange){0, 1} 
					withString:[[methodName substringToIndex:1] uppercaseString]]]];
		}
		else
		{
			methodNameComponents = [[NSArray arrayWithObject:nameToPrepend] 
				arrayByAddingObjectsFromArray:methodNameComponents];
		}
	}
	
	NSString *selectorName = [methodNameComponents componentsJoinedByString:@":"];
	if ([arguments count] > 0)
		selectorName = [selectorName stringByAppendingString:@":"];
	
	SEL selector = NSSelectorFromString(selectorName);
	
	if (![self respondsToSelector:selector])
	{
		*error = [NSError errorWithDomain:kAMFCoreErrorDomain code:kAMFErrorMethodNotFound 
			userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
				[NSString stringWithFormat:@"Service %@ does not respond to selector %@ (%@)", 
					[self className], methodName, selectorName], 
				NSLocalizedDescriptionKey, nil]];
		return nil;
	}

	NSMethodSignature *signature = [self methodSignatureForSelector:selector];	
	if (([signature numberOfArguments] - 2) != 
		(argumentToPrepend == nil ? [arguments count] : [arguments count] + 1))
	{
		*error = [NSError errorWithDomain:kAMFCoreErrorDomain code:kAMFErrorArgumentMismatch
			userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
				[NSString stringWithFormat:@"Number of arguments do not match (%d/%d)", 
					[arguments count], ([signature numberOfArguments] - 2)], 
				NSLocalizedDescriptionKey, nil]];
		return nil;
	}
	
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	[invocation setTarget:self];
	uint32_t i = 2;
	if (argumentToPrepend != nil)
		[invocation setArgument:&argumentToPrepend atIndex:i++];
	for (id argument in arguments)
		[invocation setArgument:&argument atIndex:i++];
	[invocation invoke];
	
	return [invocation returnValueAsObject];
}

@end