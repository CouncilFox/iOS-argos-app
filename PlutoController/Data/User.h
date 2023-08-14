//
//  User.h
//  PlutoController
//
//  Created by Drona Aviation on 31/07/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "RLMObject.h"

@interface User : RLMObject

@property NSString *userId;
@property NSString *userName;
@property NSString *userProfilePath;
@property bool isDeveloper;

@end

RLM_ARRAY_TYPE(User)
