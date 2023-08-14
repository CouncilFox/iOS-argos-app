//
//  ControlsViewController.h
//  PlutoController
//
//  Created by Drona Aviation on 08/05/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "LeftJoystickScene.h"
#import "RightJoystickScene.h"
#import "UserSettings.h"
#import <UIKit/UIKit.h>

@interface ControlsViewController : UIViewController {
    
    UIViewController * vc;
    UIStoryboard *storyboard;
    UserSettings *defaultUserSettings;
    RLMRealm *realm;
    RLMNotificationToken *token;
    SKView *leftSkView, *rightSkView;
    LeftJoystickScene *leftScene;
    RightJoystickScene *rightScene;
}

@end
