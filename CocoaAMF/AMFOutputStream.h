//
//  AMFOutputStream.h
//  SimpleHTTPServer
//
//  Created by Marc Bauer on 12.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>


@interface AMFOutputStream : NSObject 
{
	NSMutableData *m_data;
}

@property (nonatomic, readonly) NSData *data;

- (void)writeUInt8:(uint8_t)value;
- (void)writeUInt16:(uint16_t)value;
- (void)writeUInt29:(uint32_t)value;
- (void)writeUInt32:(uint32_t)value;
- (void)writeDouble:(double)value;
- (void)writeBool:(BOOL)value;
- (void)writeData:(NSData *)value;

@end