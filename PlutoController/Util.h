//
//  Util.h
//  PlutoController
//
//  Created by Drona Aviation on 14/06/17.
//  Copyright © 2017 Drona Aviation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Config.h"
#ifndef Util_h
#define Util_h

//PlutoCommandType
extern int NONE_COMMAND, TAKE_OFF, LAND, BACK_FLIP, FRONT_FLIP, RIGHT_FLIP, LEFT_FLIP;
extern bool isTrimSet, isAltitudeSet, isDeveloperModeSensorOn, isGPSModeOn;

@interface Util :NSObject

+ (BOOL) isConnectedToPlutoWifi;

+ (float) map:(float)x and :(float)in_min and :(float)in_max and :(float)out_min and :(float)out_max;

+ (BOOL) isCurrentFirmwareMagis;

+ (NSInteger) droneType : (NSUserDefaults*) preferences;

+ (id)sharedLeweiLib : (UIImageView *)imgMainView;

@end


#endif /* Util_h */
