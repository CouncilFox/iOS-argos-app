//
//  DroneViewController.h
//  PlutoController
//
//  Created by Drona Aviation on 08/05/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSettings.h"
#import <AVFoundation/AVFoundation.h>

@interface DroneViewController : UIViewController {
    
    UIViewController * vc;
    UIStoryboard *storyboard;
    AVAudioPlayer *audioPlayer;
    UserSettings *currentUserSettings;
}

@end


