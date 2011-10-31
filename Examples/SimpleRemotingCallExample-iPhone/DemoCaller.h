//
//  DemoCaller.h
//  CocoaAMF-iPhone
//
//  Created by Marc Bauer on 11.01.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "AMFRemotingCall.h"

@protocol DemoCallerDelegate;

@interface DemoCaller : NSObject <AMFRemotingCallDelegate>
{
	AMFRemotingCall *m_remotingCall;
	NSObject <DemoCallerDelegate> *m_delegate;
}

@property (nonatomic, assign) NSObject <DemoCallerDelegate> *delegate;

- (void)callAddMethod;
- (void)callHelloMethod;
- (void)callReturnArrayMethod;
- (void)callReturnFloatMethod;

@end


@protocol DemoCallerDelegate
- (void)callerDidFinishLoading:(DemoCaller *)caller receivedObject:(NSObject *)object;
- (void)caller:(DemoCaller *)caller didFailWithError:(NSError *)error;
@end