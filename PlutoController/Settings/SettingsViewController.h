//
//  SettingsViewController.h
//  PlutoController
//
//  Created by Drona Aviation on 08/05/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "User.h"
#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController {
    
    UIViewController * vc;
    UIStoryboard *storyboard;
    NSMutableArray *settingsData;
    User *user;
    RLMRealm *realm;
    RLMNotificationToken *token;
}

@end
