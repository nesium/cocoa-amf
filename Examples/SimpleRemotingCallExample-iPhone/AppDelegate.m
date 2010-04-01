//
//  AppDelegate.m
//  CocoaAMF
//
//  Created by Marc Bauer on 11.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (Private)
- (void)_startLoading;
- (void)_stopLoading;
- (void)_setButtonsEnabled:(BOOL)bFlag;
@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	m_caller = [[DemoCaller alloc] init];
	m_caller.delegate = self;
}

- (void)dealloc
{
	[m_caller release];
	[super dealloc];
}

- (IBAction)callAddMethod:(id)sender
{
	[m_caller callAddMethod];
	[self _startLoading];
}

- (IBAction)callHelloMethod:(id)sender
{
	[m_caller callHelloMethod];
	[self _startLoading];
}

- (IBAction)callReturnArrayMethod:(id)sender
{
	[m_caller callReturnArrayMethod];
	[self _startLoading];	
}

- (IBAction)callReturnFloatMethod:(id)sender
{
	[m_caller callReturnFloatMethod];
	[self _startLoading];	
}

- (void)callerDidFinishLoading:(DemoCaller *)caller receivedObject:(NSObject *)object
{
	[m_textView setText:[NSString stringWithFormat:@"%@", object]];
	[self _stopLoading];
}

- (void)caller:(DemoCaller *)caller didFailWithError:(NSError *)error
{
	[m_textView setText:[NSString stringWithFormat:@"%@", error]];
	[self _stopLoading];	
}


- (void)_startLoading
{
	[m_progressView startAnimating];
	[self _setButtonsEnabled:NO];
}

- (void)_stopLoading
{
	[m_progressView stopAnimating];
	[self _setButtonsEnabled:YES];
}

- (void)_setButtonsEnabled:(BOOL)bFlag
{
	[m_addButton setEnabled:bFlag];
	[m_helloButton setEnabled:bFlag];
	[m_returnArrayButton setEnabled:bFlag];
	[m_returnFloatButton setEnabled:bFlag];
}

@end