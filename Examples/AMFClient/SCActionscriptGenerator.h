//
//  SCActionscriptGenerator.h
//  CocoaAMF
//
//  Created by Marc Bauer on 02.05.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SCGenerator.h"


@interface SCActionscriptGenerator : NSObject <StubCodeGenerator>
{
}
- (NSString *)stubCodeForDataNode:(AMFDebugDataNode *)node;
@end