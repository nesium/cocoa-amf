//
//  TestObject.h
//  SimpleHTTPServer
//
//  Created by Marc Bauer on 12.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TestObject : NSObject <NSCoding>
{

}

- (id)initWithCoder:(NSCoder *)enc;
- (void)encodeWithCoder:(NSCoder *)enc;

@end