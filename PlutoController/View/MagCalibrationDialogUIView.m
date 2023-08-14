//
//  MagCalibrationDialogUIView.m
//  PlutoController
//
//  Created by Drona Aviation on 11/07/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "Realm/Realm.h"
#import "User.h"
#import "UserSettings.h"
#import "CustomProgressView.h"
#import "MagCalibrationDialogUIView.h"

@interface MagCalibrationDialogUIView()

@property (strong, nonatomic) IBOutlet UIView *magCalibrationDialogView;
@property (strong, nonatomic) IBOutlet UIView *uiViewConnector1;
@property (strong, nonatomic) IBOutlet UIView *uiViewConnector2;

@property (strong, nonatomic) IBOutlet UILabel *uiLabelCounterPhase1;
@property (strong, nonatomic) IBOutlet UILabel *uiLabelCounterPhase2;
@property (strong, nonatomic) IBOutlet UILabel *uiLabelCounterPhase3;
@property (strong, nonatomic) IBOutlet UILabel *uiLabelMagPercentage;
@property (strong, nonatomic) IBOutlet UILabel *uiLabelCalibrationInstruction;

@property (strong, nonatomic) IBOutlet UIImageView *ivCalibrationIcon;

@end

@implementation MagCalibrationDialogUIView

NSTimer *magTimer;
int magCounter;
int interval = 3;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

-(void) customInit
{
    RLMResults<User *> *users = [User objectsWhere:@"userId = 'PLUTO_DEFAULT_USER'"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"userId = %@",
                         @"PLUTO_DEFAULT_USER"];
    users = [User objectsWithPredicate:pred];
    
    RLMResults<UserSettings *> *userSettings = [UserSettings objectsWhere:@"ANY user = %@", users[0]];
    pred = [NSPredicate predicateWithFormat:@"ANY user = %@",
            users[0]];
    userSettings = [UserSettings objectsWithPredicate:pred];
    currentUserSettings = userSettings[0];
    
    NSString *path = [NSString stringWithFormat:@"%@/success_sound.wav", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1.0 alpha:0.1];
    visualEffectView.frame = self.bounds;
    [self addSubview:visualEffectView];
    
    [[NSBundle mainBundle] loadNibNamed:@"MagCalibrationDialogView" owner:self options:nil];
    
    [self addSubview:self.magCalibrationDialogView];
    
    self.magCalibrationDialogView.frame = CGRectMake(0, 0, self.frame.size.width * 0.80f, self.frame.size.height * 0.79f);
    self.magCalibrationDialogView.center = CGPointMake(self.frame.size.width * 0.5f, self.frame.size.height * 0.45f);
    
    self.magCalibrationDialogView.layer.cornerRadius = 7;
    self.magCalibrationDialogView.layer.masksToBounds = true;
    
    self.uiLabelCounterPhase1.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.uiLabelCounterPhase1.layer.borderWidth = 1.0f;
    self.uiLabelCounterPhase1.layer.cornerRadius = 13;
    self.uiLabelCounterPhase1.layer.masksToBounds = true;
    
    self.uiLabelCounterPhase2.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.uiLabelCounterPhase2.layer.borderWidth = 1.0f;
    self.uiLabelCounterPhase2.layer.cornerRadius = 13;
    self.uiLabelCounterPhase2.layer.masksToBounds = true;
    
    self.uiLabelCounterPhase3.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.uiLabelCounterPhase3.layer.borderWidth = 1.0f;
    self.uiLabelCounterPhase3.layer.cornerRadius = 13;
    self.uiLabelCounterPhase3.layer.masksToBounds = true;
    
    magCounter=0;
    
    magTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(magUpdate) userInfo:nil repeats:YES];
    [magTimer fire];
}

- (IBAction)closeMagCalibrationDialog:(id)sender {
    [magTimer invalidate];
    [self removeFromSuperview];
}

-(void)magUpdate {
    
    [(CustomProgressView *)self.magCalibrationProgressView setProgress:magCounter * 0.033];
    
    [self.uiLabelMagPercentage setText:[NSString stringWithFormat: @"%.0f %%", magCounter * 3.4f]];
    
    if(magCounter == 0) {
        self.uiLabelCounterPhase1.layer.backgroundColor = [[UIColor colorWithRed:0.07 green:0.4f blue:1.0f alpha:1.0f] CGColor];
        
    } else if(magCounter == 10) {
        if(currentUserSettings.isSounds)
            [audioPlayer play];
        
        self.uiLabelCounterPhase2.layer.backgroundColor = [[UIColor colorWithRed:0.07 green:0.4f blue:1.0f alpha:1.0f] CGColor];
        self.uiLabelCounterPhase1.alpha = 0.4f;
        self.uiViewConnector1.alpha = 0.4f;
        [self.uiLabelCalibrationInstruction setText:@"Rotate Raven 360 degrees in PITCH axis"];
        [_ivCalibrationIcon setImage:[UIImage imageNamed: @"ic_mag_pitch_drone"]];
        
    } else if (magCounter == 20){
        if(currentUserSettings.isSounds)
            [audioPlayer play];
        
        self.uiLabelCounterPhase3.layer.backgroundColor = [[UIColor colorWithRed:0.07 green:0.4f blue:1.0f alpha:1.0f] CGColor];
        self.uiLabelCounterPhase2.alpha = 0.4f;
        self.uiViewConnector2.alpha = 0.4f;
        [self.uiLabelCalibrationInstruction setText:@"Rotate Raven 360 degrees in YAW axis"];
        [_ivCalibrationIcon setImage:[UIImage imageNamed: @"ic_mag_yaw_drone"]];
        
    } else if(magCounter == 29) {
        if(currentUserSettings.isSounds)
            [audioPlayer play];
        
        [(CustomProgressView *)self.magCalibrationProgressView setProgress:1.0f];
        [self.uiLabelMagPercentage setText:[NSString stringWithFormat: @"%d %%", 100]];

    } else if(magCounter==30) {
            
        [magTimer invalidate];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
    }
    magCounter++;
}

@end
