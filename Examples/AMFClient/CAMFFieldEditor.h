//
//  CAMFFieldEditor.h
//  CocoaAMF
//
//  Created by Marc Bauer on 01.12.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CAMFFieldEditor : NSTextView 
{
}
@end

@interface NSObject (FieldEditorDelegateExtensions)
- (BOOL)fieldEditor:(NSTextView *)aView willPasteText:(NSString *)text;
@end