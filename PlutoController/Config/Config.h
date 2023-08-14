//
//  Config.h
//  PlutoController
//
//  Created by Drona Aviation on 13/09/16.
//  Copyright © 2016 Drona Aviation. All rights reserved.
//
//#include "RCSignals.h"

#import <UIKit/UIKit.h>
#import "MultiWi230.h"
#import "UIView+Toast.h"

#ifndef Config_h
#define Config_h

extern int altholdOrThrottle;
extern int sensitivity;
extern BOOL flipMode;
extern int controlType;
extern BOOL isHeadFreeMode;


@interface PlutoManager : NSObject{
 WiFiCommunication *WiFiConnection;
 MultiWi230 *protocol;
}

@property(nonatomic,retain)WiFiCommunication *WiFiConnection;
@property(nonatomic,retain)MultiWi230 *protocol;

+(id)sharedManager;

@end


extern PlutoManager *plutoManager;

#endif /* Config_h */
