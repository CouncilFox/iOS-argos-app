//
//  MagCalibrationDialogUIView.h
//  PlutoController
//
//  Created by Drona Aviation on 11/07/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MagCalibrationDialogUIView : UIView {
    AVAudioPlayer *audioPlayer;
    UserSettings *currentUserSettings;
}

@property (strong, nonatomic) IBOutlet UIProgressView *magCalibrationProgressView;

@end
