//
//  AbstractAMFTest.h
//  CocoaAMF
//
//  Created by Marc Bauer on 09.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "AMF.h"
#import "AMFByteArray.h"


@interface AbstractAMFTest : SenTestCase 
{

}

- (void)assertAMF0Data:(const char *)data length:(uint32_t)length equalsObject:(id)obj;

@end