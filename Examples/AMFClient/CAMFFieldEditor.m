//
//  CAMFFieldEditor.m
//  CocoaAMF
//
//  Created by Marc Bauer on 01.12.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "CAMFFieldEditor.h"


@implementation CAMFFieldEditor

- (BOOL)readSelectionFromPasteboard:(NSPasteboard *)pboard type:(NSString *)type
{
	BOOL delegatePerformedAction = NO;
	NSString *text = [[NSPasteboard generalPasteboard] stringForType:NSStringPboardType];
	if (![text isKindOfClass:[NSString class]])
	{
		return NO;
	}
	if ([[[self delegate] delegate] respondsToSelector:@selector(fieldEditor:willPasteText:)])
	{
		delegatePerformedAction = [[[self delegate] delegate] fieldEditor:self willPasteText:text];
	}
	if (!delegatePerformedAction)
	{
		[self insertText:text];
	}
	return !delegatePerformedAction;
}

@end