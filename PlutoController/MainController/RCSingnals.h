//
//  RCSinganls.h
//  PlutoController
//
//  Created by Drona Aviation on 13/09/16.
//  Copyright © 2016 Drona Aviation. All rights reserved.
//

#include <Foundation/Foundation.h>



#ifndef RCSinganls_h
#define RCSinganls_h

static int rc_signals_raw[8];
        

@interface RCSignals:NSObject
{

    @public
    Byte ROLL;
    Byte PITCH;
    Byte THROTTLE;
    Byte YAW;
    Byte AUX1;
    Byte AUX2;
    Byte AUX3;
    Byte AUX4;

    int rc_signals[8];
    
    int RC_MIN ;
    int RC_MAX ;
    int RC_MID ;

}


-(void) setRoll:(int) roll;

-(void) setPitch:(int) pitch;

-(void) setThrottle:(int) throttle;

-(void) setYaw:(int) yaw;

-(void) setMax:(Byte) id;

-(void) setMin:(Byte) id;

-(void) setMid:(Byte) id;

-(int) getRCSignal: (Byte)id;

-(int *) getRCSignals;

-(int) getThrottle;


@end

#endif /* RCSinganls_h */
