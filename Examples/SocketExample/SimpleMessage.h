//
//  SimpleMessage.h
//  CocoaAMF
//
//  Created by Marc Bauer on 29.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SimpleMessage : NSObject
{
	NSString *message;
}
@property (nonatomic, retain) NSString *message;
@end