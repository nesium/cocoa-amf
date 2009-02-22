//
//  AMFDuplexSocket.h
//  CocoaAMF
//
//  Created by Marc Bauer on 20.02.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMF.h"
#import "AMFActionMessage.h"
#import "AsyncSocket.h"

@class AMFInvocationResult;

@interface AMFDuplexGateway : NSObject 
{
	AsyncSocket *m_socket;
	AsyncSocket *m_remote;
	NSMutableDictionary *m_services;
	NSMutableDictionary *m_remoteServices;
	NSMutableSet *m_queuedInvocations;
	NSMutableSet *m_pendingInvocations;
	uint32_t m_invocationCount;
}

- (BOOL)startOnPort:(uint16_t)port error:(NSError **)error;
- (void)stop;

- (void)registerService:(id)service withName:(NSString *)name;
- (void)unregisterServiceWithName:(NSString *)name;

- (AMFInvocationResult *)invokeRemoteService:(NSString *)serviceName 
	methodName:(NSString *)methodName argumentsArray:(NSArray *)arguments;
- (AMFInvocationResult *)invokeRemoteService:(NSString *)serviceName 
	methodName:(NSString *)methodName arguments:(id)firstArgument, ...;
@end


@interface AMFInvocationResult : NSObject
{
	NSString *serviceName;
	NSString *methodName;
	NSArray *arguments;
	uint32_t invocationIndex;
	
	id result;
	NSString *status;
	
	id context;
	SEL action;
	id target;
}
@property (nonatomic, retain) NSString *serviceName;
@property (nonatomic, retain) NSString *methodName;
@property (nonatomic, retain) NSArray *arguments;
@property (nonatomic, assign) uint32_t invocationIndex;
@property (nonatomic, retain) id result;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) id context;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) id target;

+ (AMFInvocationResult *)invocationResultForService:(NSString *)aServiceName 
	methodName:(NSString *)aMethodName arguments:(NSArray *)args index:(uint32_t)index;
@end