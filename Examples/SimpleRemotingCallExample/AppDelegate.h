//
//  AppDelegate.h
//  CocoaAMF
//
//  Created by Marc Bauer on 11.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DemoCaller.h"


@interface AppDelegate : NSObject <DemoCallerDelegate>
{
	IBOutlet UITextView *m_textView;
	IBOutlet UIButton *m_addButton;
	IBOutlet UIButton *m_helloButton;
	IBOutlet UIButton *m_returnArrayButton;
	IBOutlet UIButton *m_returnFloatButton;
	IBOutlet UIActivityIndicatorView *m_progressView;
	
	DemoCaller *m_caller;
}

- (IBAction)callAddMethod:(id)sender;
- (IBAction)callHelloMethod:(id)sender;
- (IBAction)callReturnArrayMethod:(id)sender;
- (IBAction)callReturnFloatMethod:(id)sender;

@end