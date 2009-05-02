//
//  SCGenerator.m
//  CocoaAMF
//
//  Created by Marc Bauer on 02.05.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "SCGenerator.h"


@implementation SCGenerator

static SCGenerator *g_sharedInstance;

+ (SCGenerator *)sharedGenerator
{
	return g_sharedInstance ?: [[self new] autorelease];
}

- (id)init
{
	if (g_sharedInstance)
		[self release];
	else if (self = g_sharedInstance = [[super init] retain])
		m_generators = [[NSMutableDictionary alloc] init];
	return g_sharedInstance;
}

- (void)registerGenerator:(id <StubCodeGenerator>)gen forLanguage:(NSString *)languageName
{
	[m_generators setObject:gen forKey:languageName];
}

- (NSString *)stubCodeForDataNode:(AMFDebugDataNode *)node languageName:(NSString *)languageName
{
	id <StubCodeGenerator> gen = [m_generators objectForKey:languageName];
	return [gen stubCodeForDataNode:node];
}

- (NSArray *)languageNames
{
	return [m_generators allKeys];
}

@end