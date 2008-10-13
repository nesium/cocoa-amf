//
//  AMF0Deserializer.h
//  CocoaAMF
//
//  Created by Marc Bauer on 11.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMF.h"
#import "AMFDeserializer.h"
#import "AMF3Deserializer.h"
#import "ASObject.h"


@interface AMF0Deserializer : AMFDeserializer
{
	NSMutableArray *m_objectTable;
	AMF3Deserializer *m_avmPlusDeserializer;
}

@end