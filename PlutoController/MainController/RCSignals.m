//
//  RCSingals.m
//  PlutoController
//
//  Created by Drona Aviation on 13/09/16.
//  Copyright © 2016 Drona Aviation. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "RCSingnals.h"


@implementation RCSignals

RCSignals * remoteController1;

-(id) init {

    self=[super init];
    ROLL=0;
    PITCH=1;
    THROTTLE=2;
    YAW=3;
    AUX1=4;
    AUX2=5;
    AUX3=6;
    AUX4=7;
    
    RC_MIN = 1000;
    RC_MAX = 2000;
    RC_MID = (RC_MAX - RC_MIN) / 2 + RC_MIN;
    
    for(int i=0;i<4;i++)
      rc_signals_raw[i]=1500;
    
    for(int i=4;i<8;i++)
        rc_signals_raw[i]=1000;
    
    return self;
}

-(void) setRoll:(int)roll {
    rc_signals_raw[ROLL]=roll;
}

-(void) setPitch:(int)pitch {
    rc_signals_raw[PITCH]=pitch;
}

-(void) setThrottle:(int)throttle {
    rc_signals_raw[THROTTLE]=throttle;
}

-(int) getThrottle {
    return rc_signals_raw[THROTTLE];
}

-(void) setYaw:(int)yaw {
    rc_signals_raw[YAW]=yaw;
    //rc_signals_raw[YAW]=RC_MID;
}

-(void) setMax:(Byte)id {
    rc_signals_raw[id]=RC_MAX;
}

-(void) setMid:(Byte)id {
    rc_signals_raw[id]=RC_MID;
}

-(void) setMin:(Byte)id {
    rc_signals_raw[id]=RC_MIN;
}

-(int) getRCSignal: (Byte)id{
    return rc_signals_raw[id];
}

-(int *)getRCSignals {
    return rc_signals_raw;
}


@end
