//
//  AMFMessageHeader.h
//  SimpleHTTPServer
//
//  Created by Marc Bauer on 11.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AMFMessageHeader : NSObject 
{
	NSString *m_name;
	BOOL m_mustUnderstand;
	NSObject *m_data;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) BOOL mustUnderstand;
@property (nonatomic, retain) NSObject *data;

@end