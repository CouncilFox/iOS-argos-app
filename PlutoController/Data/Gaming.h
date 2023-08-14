//
//  Gaming.h
//  PlutoController
//
//  Created by Drona Aviation on 01/08/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "RLMObject.h"
#import <Realm/Realm.h>
#import "User.h"

@interface Gaming : RLMObject

@property int levelNo;
@property float totalFlightTime, bestTime, points;
@property RLMArray<User *><User> *user;

@end
