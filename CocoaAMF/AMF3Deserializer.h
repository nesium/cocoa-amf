//
//  AMF3Deserializer.h
//  CocoaAMF
//
//  Created by Marc Bauer on 07.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMFDeserializer.h"
#import "AMF.h"
#import "AMF3TraitsInfo.h"
#import "ASObject.h"

@interface AMF3Deserializer : AMFDeserializer 
{
	NSMutableArray *m_stringTable;
	NSMutableArray *m_objectTable;
	NSMutableArray *m_traitsTable;
}

@end