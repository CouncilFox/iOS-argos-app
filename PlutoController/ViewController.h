//
//  ViewController.h
//  HelloDrona
//
//  Created by Drona Aviation on 31/08/16.
//  Copyright © 2016 Drona Aviation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RCSingnals.h"
#import "Gaming.h"
#import "UserSettings.h"
#import "KAZ_DynamicControllerScene.h"
#import "LeweiLib/LWManage.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

extern bool isArmed;
extern int flightTimeSec;

@interface ViewController : UIViewController <CLLocationManagerDelegate, FuncManageDelegate>{
    
    UIViewController * vc;
    UIStoryboard *storyboard;
    UserSettings *userSettings;
    Gaming *gaming;
    RLMNotificationToken *token;
    SKView *skView;
    KAZ_DynamicControllerScene *scene;
    NSUserDefaults *preferences;
    CLLocationManager *locationManager;
    
    NSArray *leftGradientColor, *rightGradientColor, *leftGradientErrorColor, *rightGradientErrorColor;
    NSTimer *flightTimeTimer;
    NSTimer *RCSignalTimer;
    NSTimer *recordSDTimer;
    NSInvocationOperation *nsLandOperation;
    NSOperationQueue *nsOperationCommandQueue;
    CAGradientLayer *leftGradient, *rightGradient;
    UILongPressGestureRecognizer *longPress;
    
    LWManage *g_ManageServer;
    AVAudioPlayer *audioPlayer;
    AVAudioPlayer *audioPlayer2;
}

@property int auxType;

+(RCSignals*) getRemoteController;

-(void) startTimer;

-(void) stopTimer;

-(void) setAuxButtonStatus: (bool) isDevModeSelected;

@end

