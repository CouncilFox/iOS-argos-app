//
//  GameController.h
//  PlutoController
//
//  Created by Drona Aviation on 01/08/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "RLMObject.h"

@interface GameController : RLMObject

@property NSString *deviceId;
@property int armKeyCode, rollAxis, pitchAxis, yawAxis, throttleAxis;
@property float rollMin, rollMax, pitchMin, pitchMax, yawMin, yawMax, throttleMin, throttleMax;

@end
