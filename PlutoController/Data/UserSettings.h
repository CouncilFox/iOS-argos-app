//
//  UserSettings.h
//  PlutoController
//
//  Created by Drona Aviation on 01/08/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "RLMObject.h"
#import <Realm/Realm.h>
#import "User.h"

@interface UserSettings : RLMObject

@property NSString *themeId;
@property int flightSensitivity, flightMode, flightControl;
@property bool isHeadFreeMode, isSwipeControl, isVibrate, isSounds;
@property RLMArray<User *><User> *user;

@end
