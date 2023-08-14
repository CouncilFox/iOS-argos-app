//
//  AppSettingsController.h
//  PlutoController
//
//  Created by Drona Aviation on 17/05/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppSettingsController : UIViewController {
    UserSettings *currentUserSettings;
    RLMRealm *realm;
}

@end
