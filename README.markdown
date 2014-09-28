# CocoaAMF

CocoaAMF is a library for use by iOS applications that need to make remote requests to a server in [AMF](http://en.wikipedia.org/wiki/Action_Message_Format) format.

This is a fork of [nesium/cocoa-amf](https://github.com/nesium/cocoa-amf), simplified and updated for ARC, Xcode 6 and iOS 8.

## Installation

### Manual installation
- Clone or download the repository
- Drag the `CocoaAMF/CocoaAMF` folder into your project.

## Usage

### API invocation

Sample code for making a single remote call:

```objective-c
@interface MyClass : ... <AMFRemotingCallDelegate>
...
@end

@implementation MyClass
...
- (void)remoteCall {
    NSURL *url = [NSURL URLWithString:"https://www.myserver.com/amf-api"];
    AMFRemotingCall *call = [[AMFRemotingCall alloc] initWithURL:url
                                               			 service:@"MyService"
                                               			  method:@"mymethod"
                                             		   arguments:[NSArray arrayWithObjects:myarg, nil]];
    call.delegate = self;
	[call start];
}

- (void)remotingCallDidFinishLoading:(AMFRemotingCall *)remotingCall 
					  receivedObject:(NSObject *)object {
	// Handle response here
}

- (void)remotingCall:(AMFRemotingCall *)remotingCall
	didFailWithError:(NSError *)error {
	// Handle error here
}
...
@end
```

If you plan to make multiple remote calls to the same server and/or endpoint, you can initialize `AMFRemotingCall` just once and re-use it for each invocation:

```objective-c
AMFRemotingCall *call;

- (id)init {
	...
	call = [[AMFRemotingCall alloc] init];
	call.URL = [NSURL URLWithString:@"https://www.myserver.com/amf-api"];
	call.delegate = self;
	...
}

- (void)remoteCall1 {
	call.service = @"MyService1";
	call.method = @"mymethod1";
	call.arguments = [NSArray arrayWithObjects:myarg1, nil];
	[call start];
}

- (void)remoteCall2 {
	call.service = @"MyService2";
	call.method = @"mymethod2";
	call.arguments = [NSArray arrayWithObjects:myarg2, nil];
	[call start];
}

```

For a sample iOS application, see `Examples\SimpleRemotingCallExample`.

### Serialization

CocoaAMF uses the NSCoding protocol to serialize and deserialize objects. Here's a sample implementation of this protocol for a class `MyClass` with two properties: a number and a string.

```objective-c
@interface MyClass : NSObject <NSCoding> {
    NSNumber *property1;
    NSString *property2;
}

@property (nonatomic) NSNumber *property1;
@property (nonatomic) NSString *property2;

@end

@implementation MyClass

@synthesize property1;
@synthesize property2;

- (id)initWithCoder:(NSCoder *)coder {
	if( self = [self init] ) {
        NSObject *obj = [coder decodeObject];
		self.property1 = [obj valueForKey:@"property1"];
		self.property2 = [obj valueForKey:@"property2"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:property1 forKey:@"property1"];
	[encoder encodeObject:property2 forKey:@"property2"];
}

@end
```

Next, associate your class with the remote classname. The following code associates `MyClass` to the remote class `com.mycompany.MyClass` and vice-versa:

```objective-c
[AMFUnarchiver setClass:[MyClass class] forClassName:@"com.mycompany.MyClass"];
[AMFArchiver setClassName:@"com.mycompany.MyClass" forClass:[MyClass class]];
```

A good place to do these associations is during application initialization, before you make any remote calls.

When deserializing, if no class with the classname of the received object is found, CocoaAMF creates an instance of ASObject which will contain all attributes of that object and its classname as the ivar 'type'.

## Credits

This version of CocoaAMF was created by [Arun Nair](http://nairteashop.org) as a fork of [Marc Bauer's CocoaAMF library](https://github.com/nesium/cocoa-amf). If you use this code in your project, attribution is appreciated.
