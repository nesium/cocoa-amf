//
//  AMF3Test.h
//  CocoaAMF
//
//  Created by Marc Bauer on 20.02.09.
//  Copyright 2009 Fork Unstable Media GmbH. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "AbstractAMFTest.h"
#import "ASObject.h"
#import "AMFArchiver.h"
#import "FlexDataTypes.h"


@interface AMF3Test : AbstractAMFTest 
{

}
@end


@interface WrongSerializedCustomObject : NSObject
{
}
@end

@interface PlainStringEncoder : NSObject
{
	NSString *m_string;
}
@end