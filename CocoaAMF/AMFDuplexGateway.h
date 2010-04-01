//
//  AMFDuplexSocket.h
//  CocoaAMF
//
//  Created by Marc Bauer on 20.02.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMF.h"
#import "AMFActionMessage.h"
#import "AsyncSocket.h"
#import "NSInvocation-AMFExtensions.h"
#import <objc/runtime.h>

@class AMFInvocationResult;
@class AMFRemoteGateway;

typedef enum _AMFDuplexGatewayMode
{
	kAMFDuplexGatewayModeNotConnected,
	kAMFDuplexGatewayModeServer,
	kAMFDuplexGatewayModeClient
} AMFDuplexGatewayMode;

typedef enum _AMFRemoteGatewayType{
	kAMFRemoteGatewayTypeIncoming, 
	kAMFRemoteGatewayTypeOutgoing
} AMFRemoteGatewayType;


@interface AMFDuplexGateway : NSObject
{
	AsyncSocket *m_socket;
	NSMutableSet *m_remoteGateways;
	NSMutableDictionary *m_services;
	id m_delegate;
	AMFDuplexGatewayMode m_mode;
	Class m_remoteGatewayClass;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) AMFDuplexGatewayMode mode;

- (BOOL)startOnPort:(uint16_t)port error:(NSError **)error;
- (BOOL)connectToRemote:(NSString *)server port:(uint16_t)port error:(NSError **)error;
- (void)stop;

- (UInt16)localPort;

- (void)registerService:(id)service withName:(NSString *)name;
- (void)unregisterServiceWithName:(NSString *)name;
- (id)serviceWithName:(NSString *)name;

- (void)setRemoteGatewayClass:(Class)aClass;
- (NSSet *)remoteGateways;

- (void)remoteGatewayDidDisconnect:(AMFRemoteGateway *)remoteGateway;
@end


@interface NSObject (AMFDuplexGatewayDelegate)
- (void)gateway:(AMFDuplexGateway *)gateway remoteGatewayDidConnect:(AMFRemoteGateway *)remote;
- (void)gateway:(AMFDuplexGateway *)gateway remoteGatewayDidDisconnect:(AMFRemoteGateway *)remote;
@end


@interface AMFRemoteGateway : NSObject
{
	id m_delegate;
	AMFDuplexGateway *m_localGateway;
	AsyncSocket *m_socket;
	NSMutableSet *m_queuedInvocations;
	NSMutableSet *m_pendingInvocations;
	uint32_t m_invocationCount;
	AMFRemoteGatewayType m_gatewayType;
	BOOL m_binaryMode;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) AMFDuplexGateway *localGateway;
- (id)initWithLocalGateway:(AMFDuplexGateway *)localGateway socket:(AsyncSocket *)socket 
	type:(AMFRemoteGatewayType)gatewayType;
- (AMFInvocationResult *)invokeRemoteService:(NSString *)serviceName 
	methodName:(NSString *)methodName argumentsArray:(NSArray *)arguments;
- (AMFInvocationResult *)invokeRemoteService:(NSString *)serviceName 
	methodName:(NSString *)methodName arguments:(id)firstArgument, ...;
- (void)disconnect;
@end


@interface AMFInvocationResult : NSObject
{
	AMFRemoteGateway *gateway;
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
@property (nonatomic, assign) AMFRemoteGateway *gateway;
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