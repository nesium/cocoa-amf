//
//  AMF0Serializer.h
//  SimpleHTTPServer
//
//  Created by Marc Bauer on 12.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMF.h"
#import "AMFOutputStream.h"


@interface AMF0Serializer : NSObject 
{
	AMFOutputStream *m_stream;
	BOOL m_avmPlus;
}

- (id)initWithStream:(AMFOutputStream *)stream avmPlus:(BOOL)avmPlus;
- (void)serialize:(NSObject *)value;

@end