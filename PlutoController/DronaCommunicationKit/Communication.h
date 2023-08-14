//
//  Communication.h
//  PlutoController
//
//  Created by Drona Aviation on 01/09/16.
//  Copyright © 2016 Drona Aviation. All rights reserved.
//

#include <Foundation/Foundation.h>

#ifndef Communication_h
#define Communication_h

static NSString *const plutoHOST = @"192.168.4.1";
static int plutoPORT = 23;
static NSString *const cameraHOST = @"192.168.0.1";
static int cameraPORT = 9060;

@protocol CommunicationProtocol <NSObject>

@required

-(int) connect: (bool) connectToCameraTCP;

-(void) disconnect;

-(void) write:(NSMutableData *)data;

-(void) read;

-(void) removeInputStreamDelegate;

-(void) setInputStreamDelegate;

@end


@interface WiFiCommunication : NSObject<NSStreamDelegate,CommunicationProtocol> {

}
@property BOOL connected;
@property uint8_t flash_char;

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode;

@end

#endif /* Communication_h */
