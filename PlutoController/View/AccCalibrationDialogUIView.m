//
//  CalibrationDialogUIView.m
//  PlutoController
//
//  Created by Drona Aviation on 03/07/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "Realm/Realm.h"
#import "User.h"
#import "UserSettings.h"
#import "CustomProgressView.h"
#import "AccCalibrationDialogUIView.h"

@interface AccCalibrationDialogUIView()

@property (strong, nonatomic) IBOutlet UIView *calibrationDialogView;

@property (strong, nonatomic) IBOutlet UILabel *uiLabelCalibrationPercentage;

@end

@implementation AccCalibrationDialogUIView

NSTimer *accTimer;
int accCounter;

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
    
    [[NSBundle mainBundle] loadNibNamed:@"AccCalibrationDialogView" owner:self options:nil];
    
    [self addSubview:self.calibrationDialogView];

    self.calibrationDialogView.frame = CGRectMake(0, 0, self.frame.size.width * 0.73f, self.frame.size.height * 0.65f);
    self.calibrationDialogView.center = CGPointMake(self.frame.size.width * 0.5f, self.frame.size.height * 0.45f);
    
    self.calibrationDialogView.layer.cornerRadius = 7;
    self.calibrationDialogView.layer.masksToBounds = true;
        
    accCounter=0;
    accTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(accUpdate) userInfo:nil repeats:YES];
    [accTimer fire];
    
}

- (IBAction)closeCalibrationDialog:(id)sender {
    [accTimer invalidate];
    [self removeFromSuperview];
}

-(void)accUpdate {
    
    [(CustomProgressView *)self.calibrationProgressView setProgress:accCounter * 0.25];
    
    [self.uiLabelCalibrationPercentage setText:[NSString stringWithFormat: @"%d %%", accCounter * 25]];
    
    if(accCounter==4){
        if(currentUserSettings.isSounds)
            [audioPlayer play];
    }
    else if(accCounter==5)
    {
        [accTimer invalidate];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
    }
    accCounter++;
}

@end
