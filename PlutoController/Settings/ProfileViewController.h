//
//  ProfileViewController.h
//  PlutoController
//
//  Created by Drona Aviation on 08/05/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "Gaming.h"
#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController {
    
    UIViewController * vc;
    UIStoryboard *storyboard;
    User *defaultUser;
    Gaming *gaming;
    RLMNotificationToken *token;
}

@end
