//
//  CalibrationDialogUIView.h
//  PlutoController
//
//  Created by Drona Aviation on 03/07/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSettings.h"
#import <AVFoundation/AVFoundation.h>

@interface AccCalibrationDialogUIView : UIView {
    AVAudioPlayer *audioPlayer;
    UserSettings *currentUserSettings;
}

@property (strong, nonatomic) IBOutlet UIProgressView *calibrationProgressView;

@end
