//
//  AMFMessageBody.h
//  SimpleHTTPServer
//
//  Created by Marc Bauer on 11.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AMFMessageBody : NSObject 
{
	NSString *m_targetURI;
	NSString *m_responseURI;
	NSObject *m_data;
}

@property (nonatomic, retain) NSString *targetURI;
@property (nonatomic, retain) NSString *responseURI;
@property (nonatomic, retain) NSObject *data;

@end