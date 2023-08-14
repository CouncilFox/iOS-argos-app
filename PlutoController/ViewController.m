//
//  ViewController.m
//  PlutoController
//
//  Created by Drona Aviation on 01/09/16.
//  Copyright © 2016 Drona Aviation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import "AuxDialogOptionUIView.h"
#import "Util.h"
#import "Config.h"
#import "MultiWi230.h"
#import "Communication.h"
#import "RCSingnals.h"
#import <Photos/Photos.h>
#import "ViewController.h"

@interface ViewController () <WCSessionDelegate>

@property (weak, nonatomic) IBOutlet UIView *skUIView;
@property (weak, nonatomic) IBOutlet UIView *minView;
@property (weak, nonatomic) IBOutlet UIView *secView;
@property (weak, nonatomic) IBOutlet UIView *timerBackground;
@property (weak, nonatomic) IBOutlet UIView *swipeView;
@property (weak, nonatomic) IBOutlet UIView *cameraModuleView;
@property (weak, nonatomic) IBOutlet UIView *videoTimerContainer;

@property (weak, nonatomic) IBOutlet UILabel *rollLabel;
@property (weak, nonatomic) IBOutlet UILabel *pitchLabel;
@property (weak, nonatomic) IBOutlet UILabel *yawLabel;
@property (weak, nonatomic) IBOutlet UILabel *rollValue;
@property (weak, nonatomic) IBOutlet UILabel *pitchValue;
@property (weak, nonatomic) IBOutlet UILabel *yawValue;
@property (weak, nonatomic) IBOutlet UILabel *altModeStatus;
@property (weak, nonatomic) IBOutlet UILabel *flightStatus;
@property (weak, nonatomic) IBOutlet UILabel *batteryValue;
@property (weak, nonatomic) IBOutlet UILabel *timerSec;
@property (weak, nonatomic) IBOutlet UILabel *timerMin;
@property (weak, nonatomic) IBOutlet UILabel *flipUnsupportLabel;
@property (weak, nonatomic) IBOutlet UILabel *sdCardLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoTimerLabel;

@property (weak, nonatomic) IBOutlet UIImageView *batteryIcon;
@property (weak, nonatomic) IBOutlet UIImageView *timerIcon;
@property (weak, nonatomic) IBOutlet UIImageView *ivPlayerView;

@property (weak, nonatomic) IBOutlet UISwitch *armSwitch;

@property (weak, nonatomic) IBOutlet UIButton *btnConnectPluto;
@property (weak, nonatomic) IBOutlet UIButton *btnSettings;
@property (weak, nonatomic) IBOutlet UIButton *btnAux;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnVideo;
@property (weak, nonatomic) IBOutlet UIButton *btnLensFlip;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthBatteryLabel;


@property (nonatomic, retain) CMMotionManager *motionManager;
@property (nonatomic, retain) CMMotionManager *yawMotionManager;

@end

static NSString *const CONNECT_STATE = @"CONNECT";
static NSString *const TAKE_OFF_STATE = @"TAKE OFF";
static NSString *const LAND_STATE = @"LAND";
static NSString *const DISCONNECT_STATE = @"DISCONNECT";
static int FLIP_MODE = 0;
static int DEVELOPER_MODE = 1;

static RCSignals *remoteControl1;
double lastRefreshTime=0;
bool STOP_RC_SIGNAL=FALSE;
PlutoManager *plutoManager;
int controlstate=0, boundryValue=50, flightTimeSec = 0, alpha = 0, recordSDSec = 0;
int commandType, deviceYaw, deviceLat, deviceLong;
bool isArmed=FALSE;
bool autoConnect = false;
const float battery_max = 4.0f;
const float battery_min = 3.45f;
bool isTimerPaused= false;
bool isTimerStarted = false;

AuxDialogOptionUIView *auxDialogOptionUIView;

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    CGRect frame = CGRectMake(0, 0, _timerBackground.frame.size.width, _timerBackground.frame.size.height);
    gradient.frame            = frame;
    gradient.colors           = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:1.0 green:0.54  blue:0.33 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:1.0 green:0.36 blue:0.64 alpha:1.0] CGColor], nil];
    gradient.cornerRadius = 20;
    gradient.startPoint = CGPointMake(0, 0.6);
    gradient.endPoint = CGPointMake(1, 0.4);
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.lineWidth = 4;
    shape.path =  [UIBezierPath bezierPathWithRoundedRect: _timerBackground.bounds byRoundingCorners: UIRectCornerAllCorners cornerRadii: (CGSize){20.0, 20.0}].CGPath;
    shape.strokeColor = [UIColor whiteColor].CGColor;
    shape.fillColor   = [UIColor clearColor].CGColor;
    gradient.mask = shape;
    [_timerBackground.layer insertSublayer:gradient atIndex:0];
    _timerBackground.layer.cornerRadius = 20;
    _timerBackground.clipsToBounds = YES;
    
    _btnAux.layer.cornerRadius = 22;
    _btnAux.clipsToBounds = YES;
    longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(auxLongPress)];
    
    _btnConnectPluto.layer.cornerRadius = 20;
    _btnConnectPluto.clipsToBounds = YES;
    [_btnConnectPluto.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnConnectPluto layer] setBorderWidth:6.0f];
    
    _btnSettings.layer.cornerRadius = 4;
    _btnSettings.clipsToBounds = YES;
    
    [_timerIcon setImage:[UIImage imageNamed: @"flight_time_icon.png"]];
    
    _armSwitch.userInteractionEnabled = NO;
    _armSwitch.alpha = 0.5f;
    
    _minView.layer.masksToBounds = YES;
    _minView.layer.cornerRadius = 8;
    _minView.backgroundColor = [UIColor lightGrayColor];
    _timerMin.textAlignment = NSTextAlignmentCenter;
    _timerMin.text = @"00";
    _timerMin.numberOfLines = 1;
    [_timerMin sizeToFit];
    
    _secView.layer.masksToBounds = YES;
    _secView.layer.cornerRadius = 8;
    _secView.backgroundColor = [UIColor lightGrayColor];
    _timerSec.textAlignment = NSTextAlignmentCenter;
    _timerSec.text = @"00";
    _timerSec.numberOfLines = 1;
    [_timerSec sizeToFit];
    
    _timerMin.alpha = 1;
    _timerSec.alpha = 1;
    
    leftGradientColor = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2] CGColor], nil];
    rightGradientColor = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    leftGradientErrorColor = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithRed:1.0f green:0 blue:0 alpha:0.3] CGColor], nil];
    rightGradientErrorColor = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:1.0f green:0 blue:0 alpha:0.3] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    
    leftGradient = [CAGradientLayer layer];
    frame = CGRectMake(0, 0, 263.5, 20);
    frame.origin.x = -200;
    leftGradient.frame = frame;
    leftGradient.colors = leftGradientColor;
    leftGradient.startPoint = CGPointMake(0, 0.6);
    leftGradient.endPoint = CGPointMake(1, 0.4);
    rightGradient = [CAGradientLayer layer];
    frame = CGRectMake(0, 0, 363, 20);
    frame.origin.x = _flightStatus.bounds.size.width * 0.5;
    rightGradient.frame = frame;
    rightGradient.colors = rightGradientColor;
    rightGradient.startPoint = CGPointMake(0, 0.6);
    rightGradient.endPoint = CGPointMake(1, 0.4);
    
    [_flightStatus.layer insertSublayer:rightGradient atIndex:1];
    [_flightStatus.layer insertSublayer:leftGradient atIndex:0];
    _flightStatus.textAlignment = NSTextAlignmentCenter;
    _flightStatus.text = @"NOT CONNECTED";
    _flightStatus.numberOfLines = 1;
    [_flightStatus sizeToFit];
    
    _altModeStatus.text = @"Alt mode or throttle mode";
    _altModeStatus.numberOfLines = 1;
    [_altModeStatus sizeToFit];
    
    if(!plutoManager&&!remoteControl1) {
        plutoManager=[PlutoManager sharedManager];
        remoteControl1=[[RCSignals alloc]init];
    }
    
    STOP_RC_SIGNAL=FALSE;
    _auxType = DEVELOPER_MODE;
    
    skView = (SKView *)_skUIView;
    scene = [KAZ_DynamicControllerScene sceneWithSize:skView.bounds.size];
    skView.multipleTouchEnabled = YES;
    skView.allowsTransparency = YES;
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [skView presentScene:scene];
    
    nsOperationCommandQueue = [NSOperationQueue mainQueue];
    
    if(!requests) {
        requests=[NSMutableArray array];
        [requests addObject:[NSNumber numberWithInt:MSP_FLIGHT_STATUS]];
    }
    
    [self initController];
    
    RLMResults<User *> *users = [User objectsWhere:@"userId = 'PLUTO_DEFAULT_USER'"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"userId = %@",
                         @"PLUTO_DEFAULT_USER"];
    users = [User objectsWithPredicate:pred];
    
    RLMResults<UserSettings *> *userSettingsResult = [UserSettings objectsWhere:@"ANY user = %@", users[0]];
    pred = [NSPredicate predicateWithFormat:@"ANY user = %@",
            users[0]];
    userSettingsResult = [UserSettings objectsWithPredicate:pred];
    userSettings = userSettingsResult[0];
    sensitivity = userSettings.flightSensitivity;
    
    token = [userSettings addNotificationBlock:^(BOOL deleted,
                                                 NSArray<RLMPropertyChange *> *changes,
                                                 NSError *error) {
        if (deleted) {
            NSLog(@"The object was deleted.");
        } else if (error) {
            NSLog(@"An error occurred: %@", error);
        } else {
            for (RLMPropertyChange *property in changes) {
                if ([property.name isEqualToString:@"flightSensitivity"])
                    sensitivity = [property.value intValue];
            }
        }
    }];
    
    [self startRCSignalTimer];
    
    RLMResults<Gaming *> *gamingResult = [Gaming objectsWhere:@"ANY user = %@", users[0]];
    pred = [NSPredicate predicateWithFormat:@"ANY user = %@",
            users[0]];
    gamingResult = [Gaming objectsWithPredicate:pred];
    gaming = gamingResult[0];
    
    if (g_ManageServer==nil) {
        g_ManageServer = [Util sharedLeweiLib:_ivPlayerView];
        g_ManageServer.delegate = self;
        [g_ManageServer setViewStatus: VIEW_State_Logo];
        [g_ManageServer StartManageServer];
        
        [_btnCamera setUserInteractionEnabled: NO];
        [_btnVideo setUserInteractionEnabled: NO];
        [_btnLensFlip setUserInteractionEnabled: NO];
        [_cameraModuleView setAlpha: 0.4f];
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/shutter.wav", [[NSBundle mainBundle] resourcePath]];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
    
    NSString *path2 = [NSString stringWithFormat:@"%@/error_sound.wav", [[NSBundle mainBundle] resourcePath]];
    audioPlayer2 = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path2] error:nil];
    
    UISwipeGestureRecognizer *swipeRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
    [_swipeView addGestureRecognizer:swipeRight];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [token invalidate];
    
    [g_ManageServer StopManageServer];
}

-(void)viewWillAppear:(BOOL)animated {
    
    preferences = [NSUserDefaults standardUserDefaults];
    
    if(userSettings.user[0].isDeveloper) {
        [_btnAux addGestureRecognizer:longPress];
        if(![preferences boolForKey:@"default_aux_mode"])
            [self setAuxButtonStatus:YES];
        else
            [self setAuxButtonStatus:NO];
        
        _batteryValue.hidden = NO;
        _widthBatteryLabel.constant = 46;
        [self.view layoutIfNeeded];
    }
    else {
        [self setAuxButtonStatus:NO];
        [remoteControl1 setMin: remoteControl1->AUX2];
        [preferences setBool:NO forKey:@"default_aux_mode"];
        [preferences setBool:NO forKey:@"show_flight_data"];
        _batteryValue.hidden = NO;
        _widthBatteryLabel.constant = 0;
        [self.view layoutIfNeeded];
    }
    
    bool isShowFlightData = [preferences boolForKey:@"show_flight_data"];
    [_rollValue setHidden: !isShowFlightData];
    [_pitchValue setHidden: !isShowFlightData];
    [_yawValue setHidden: !isShowFlightData];
    [_rollLabel setHidden: !isShowFlightData];
    [_pitchLabel setHidden: !isShowFlightData];
    [_yawLabel setHidden: !isShowFlightData];
    
    altholdOrThrottle = userSettings.flightMode;
    
    if(altholdOrThrottle)
        [remoteControl1 setMin: remoteControl1->AUX3];
    else
        [remoteControl1 setMid: remoteControl1->AUX3];
    [scene setInnerControlForAltHoldThrottle];
    
    isHeadFreeMode = userSettings.isHeadFreeMode;
    
    if (isHeadFreeMode)
        [remoteControl1 setMid: remoteControl1->AUX1];
    else
        [remoteControl1 setMin: remoteControl1->AUX1];
    
    controlType = userSettings.flightControl;
    if(controlType) {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        [self.motionManager startDeviceMotionUpdatesToQueue:queue withHandler:^(CMDeviceMotion *motion, NSError *error) {
            
            tiltRoll=motion.attitude.roll*57.2957795;
            tiltPitch=motion.attitude.pitch*57.2957795;
            
            if(tiltRoll>boundryValue) {
                tiltRoll=boundryValue;
            }
            else if (tiltRoll<-boundryValue) {
                tiltRoll= -boundryValue;
            }
            
            if(tiltPitch>boundryValue) {
                tiltPitch=boundryValue;
            }
            else if (tiltPitch<-boundryValue) {
                tiltPitch= -boundryValue;
            }
        }];
    }
    
    if(isDeveloperModeSensorOn)
        [self getDeviceYawUpdates];
    
    if(isGPSModeOn)
        [self startLocationUpdates];
    
    commandType = NONE_COMMAND;
    STOP_RC_SIGNAL=FALSE;
    
    if(plutoManager.WiFiConnection.connected) {
        if(isTrimSet) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [plutoManager.protocol sendRequestMSP_SET_ACC_TRIM:trim_pitch and:trim_roll];
                [plutoManager.protocol sendRequestMSP_EEPROM_WRITE];
            });
        }
        
        if(isAltitudeSet) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [plutoManager.protocol sendRequestMSP_SET_MAX_ALT:maxAlt];
                
                NSLog(@"max alt set: %d", maxAlt);
            });
        }
        
        if(controlstate == 2)
            controlstate = 1;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    if(userSettings.user[0].isDeveloper)
        [_btnAux removeGestureRecognizer:longPress];
    
    if(userSettings.flightControl) {
        [self.motionManager stopDeviceMotionUpdates];
        self.motionManager = nil;
    }
    
    if(isDeveloperModeSensorOn) {
        [self.yawMotionManager stopDeviceMotionUpdates];
        self.yawMotionManager = nil;
    }
    
    if(isGPSModeOn) {
        [self.locationManager stopUpdatingLocation];
        locationManager = nil;
    }
    
    [g_ManageServer stopLocalRecordVideo];
    if(!_sdCardLabel.isHidden) [g_ManageServer recordVideoCard];
    [g_ManageServer setViewStatus: VIEW_State_Logo];
    
    STOP_RC_SIGNAL=TRUE;
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    
    if(autoConnect){
        autoConnect = false;
        bool connectToCameraTCP = ![Util isConnectedToPlutoWifi];
        
        [plutoManager.WiFiConnection connect: connectToCameraTCP];
        
        controlstate=1;
    }
    
    if(isTimerStarted){
        _timerMin.alpha = 1;
        _timerSec.alpha = 1;
        [self removeAnimation];
        [self startAnimation];
    }
    
    if(plutoManager.WiFiConnection.connected && controlstate == 2)
        controlstate = 1;
    
    STOP_RC_SIGNAL = FALSE;
}

- (void)appWillResignActive:(NSNotification *)notification {
    [g_ManageServer stopLocalRecordVideo];
    if(!_sdCardLabel.isHidden) [g_ManageServer recordVideoCard];
    [g_ManageServer setViewStatus: VIEW_State_Logo];
    
    STOP_RC_SIGNAL = TRUE;
}

- (IBAction)ConnectPluto:(id)sender {
    
    if(!plutoManager.WiFiConnection.connected) {
        
        if([plutoManager.WiFiConnection connect: ![Util isConnectedToPlutoWifi]] == 7) {
            autoConnect = true;
            [self.view makeToast:@"Please connect to Raven Wifi"];
        }
        
        controlstate=1;
    }
    
    else if (isArmed && [[_btnConnectPluto titleForState:UIControlStateNormal] isEqualToString:TAKE_OFF_STATE]) {
        commandType = TAKE_OFF;
        [_btnConnectPluto setEnabled:NO];
        _btnConnectPluto.alpha = 0.5f;
        _btnConnectPluto.userInteractionEnabled = NO;
        
        nsLandOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(landTask) object:nil];
        [nsOperationCommandQueue addOperation:nsLandOperation];
        
    }
    else if (isArmed && [[_btnConnectPluto titleForState:UIControlStateNormal] isEqualToString:LAND_STATE]) {
        commandType = LAND;
        [_btnConnectPluto setEnabled:NO];
        _btnConnectPluto.alpha = 0.5f;
        _btnConnectPluto.userInteractionEnabled = NO;
    }
    else{
        [self disconnectPluto];
    }
    
}


-(void)disconnectPluto{
    [remoteControl1 setMin: remoteControl1->AUX4 ];
    [plutoManager.protocol sendRequestMSP_RAW_RC:[remoteControl1 getRCSignals]];
    usleep(10000);
    [plutoManager.WiFiConnection disconnect];
    
    [_armSwitch setOn:FALSE];
    _armSwitch.userInteractionEnabled = NO;
    _armSwitch.alpha = 0.5f;
    
    controlstate=0;
    [self stopTimer];
    isTimerStarted = false;
    [self removeAnimation];
    
    [_btnConnectPluto setTitle:CONNECT_STATE forState:UIControlStateNormal];
    [_btnConnectPluto setTitleColor:[UIColor colorWithRed:210.0f/255.0f green:17.0f/255.0f blue:95.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    _flightStatus.text = @"NOT CONNECTED";
    _flightStatus.textColor = [UIColor colorWithRed:1.0f green:138.0f/255.0f blue:85.0f/255.0f alpha:1.0f];
    leftGradient.colors = leftGradientColor;
    rightGradient.colors = rightGradientColor;
    
    [_rollValue setText:@"--"];
    [_pitchValue setText:@"--"];
    [_yawValue setText:@"--"];
    [_batteryIcon setImage: [UIImage imageNamed: @"ic_no_battery"]];
    [_batteryValue setText:@"- V"];
    
    FLIGHT_CONTROLLER_ID = nil;
    BOARD_ID = nil;
    
    _btnAux.alpha = 0.5f;
    [remoteControl1 setMin: remoteControl1->AUX2];
    
    [g_ManageServer stopLocalRecordVideo];
    if(!_sdCardLabel.isHidden) [g_ManageServer recordVideoCard];
    [g_ManageServer setViewStatus:VIEW_State_Logo];
    [_ivPlayerView setHidden: YES];
    [_btnCamera setUserInteractionEnabled: NO];
    [_btnVideo setUserInteractionEnabled: NO];
    [_btnLensFlip setUserInteractionEnabled: NO];
    [_cameraModuleView setAlpha: 0.4f];
}

- (IBAction)armSwitch:(id)sender {
    
    if([sender isOn]) {
        command_status = 2;
        current_command = NONE_COMMAND;
        
        if (userSettings.flightMode == 1)
            [remoteControl1 setMin:remoteControl1->THROTTLE ];
        else
            [remoteControl1 setMid:remoteControl1->THROTTLE ];
        
        [remoteControl1 setMid:remoteControl1->AUX4 ];
        isArmed=TRUE;
        [_timerMin setText:@"00"];
        [_timerSec setText:@"00"];
        
        if ([Util isCurrentFirmwareMagis]) {
            if (!altholdOrThrottle){
                [_btnConnectPluto setTitle:TAKE_OFF_STATE forState:UIControlStateNormal];
                [_btnConnectPluto setTitleColor:[UIColor colorWithRed:18.0f/255.0f green:186.0f/255.0f blue:144.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
                
                if(_auxType == FLIP_MODE)
                    _btnAux.alpha = 1.0f;
            }
        } else if(_auxType == FLIP_MODE && !altholdOrThrottle) {
            [_flipUnsupportLabel setHidden:NO];
        }
    }
    else {
        [self performDisarm];
        [self gamingLogicTask];
    }
    
}

- (IBAction)onRecordVideo:(id)sender {
    
    if([g_ManageServer getCardStatus] == 1) {
        [g_ManageServer recordVideoCard];
    } else {
        [g_ManageServer recordVideo];
    }
}

- (IBAction)onCameraClick:(id)sender {
    
    [g_ManageServer snapPhoto];
}

- (IBAction)onLensFlip:(id)sender {
    [g_ManageServer cameraFlip];
}

-(void)updateFlightStatus {
    
    switch (flightIndicatorFlag) {
        case 0:
            [_flightStatus setText: @"CALIBRATE ACCELEROMETER"];
            [_flightStatus setTextColor:[UIColor whiteColor]];
            leftGradient.colors = leftGradientErrorColor;
            rightGradient.colors = rightGradientErrorColor;
            break;
        case 1:
            [_flightStatus setText: @"CALIBRATE MAGNETOMETER"];
            [_flightStatus setTextColor:[UIColor whiteColor]];
            leftGradient.colors = leftGradientErrorColor;
            rightGradient.colors = rightGradientErrorColor;
            break;
        case 2:
            [_flightStatus setText: @"ARMED"];
            [_flightStatus setTextColor:[UIColor colorWithRed:29.0f/255.0f green:233.0f/255.0f blue:182.0f/255.0f alpha:1.0f]];
            leftGradient.colors = leftGradientColor;
            rightGradient.colors = rightGradientColor;
            _armSwitch.userInteractionEnabled = YES;
            _armSwitch.alpha = 1.0f;
            [self startTimer];
            break;
        case 3:
            [_flightStatus setText: @"READY TO ARM"];
            [_flightStatus setTextColor:[UIColor colorWithRed:29.0f/255.0f green:233.0f/255.0f blue:182.0f/255.0f alpha:1.0f]];
            leftGradient.colors = leftGradientColor;
            rightGradient.colors = rightGradientColor;
            _armSwitch.userInteractionEnabled = YES;
            _armSwitch.alpha = 1.0f;
            break;
        case 4:
            [_flightStatus setText: @"KEEP RAVEN ON FLAT SURFACE"];
            [_flightStatus setTextColor:[UIColor whiteColor]];
            leftGradient.colors = leftGradientErrorColor;
            rightGradient.colors = rightGradientErrorColor;
            [_armSwitch setOn: FALSE];
            _armSwitch.userInteractionEnabled = NO;
            _armSwitch.alpha = 0.5f;
            break;
        case 5:
            [_flightStatus setText: @"SIGNAL LOSS"];
            [_flightStatus setTextColor:[UIColor whiteColor]];
            leftGradient.colors = leftGradientErrorColor;
            rightGradient.colors = rightGradientErrorColor;
            break;
        case 6:
            [_armSwitch setOn:FALSE];
            [self performDisarm];
            _armSwitch.userInteractionEnabled = NO;
            _armSwitch.alpha = 0.5f;
            [_flightStatus setText: @"CRASHED"];
            [_flightStatus setTextColor:[UIColor whiteColor]];
            leftGradient.colors = leftGradientErrorColor;
            rightGradient.colors = rightGradientErrorColor;
            break;
        case 7:
            [_flightStatus setText: @"LOW BATTERY in-flight"];
            [_flightStatus setTextColor:[UIColor whiteColor]];
            leftGradient.colors = leftGradientErrorColor;
            rightGradient.colors = rightGradientErrorColor;
            [_flightStatus sizeToFit];
            break;
        case 8:
            [_flightStatus setText: @"LOW BATTERY"];
            [_flightStatus setTextColor:[UIColor whiteColor]];
            leftGradient.colors = leftGradientErrorColor;
            rightGradient.colors = rightGradientErrorColor;
            [_armSwitch setOn:FALSE];
            [self performDisarm];
            _armSwitch.userInteractionEnabled = NO;
            _armSwitch.alpha = 0.5f;
            break;
        default:
            [_flightStatus setText: @"RAVEN CONNECTED"];
            [_flightStatus setTextColor:[UIColor colorWithRed:29.0f/255.0f green:233.0f/255.0f blue:182.0f/255.0f alpha:1.0f]];
            leftGradient.colors = leftGradientColor;
            rightGradient.colors = rightGradientColor;
            _armSwitch.userInteractionEnabled = YES;
            _armSwitch.alpha = 1.0f;
            break;
    }
}

-(void)updateBatteryIcon {
    if (battery >= battery_max) {
        [_batteryIcon setImage: [UIImage imageNamed: @"ic_battery_full"]];
    } else if (battery >= 3.7f) {
        [_batteryIcon setImage: [UIImage imageNamed: @"ic_battery_two_bar"]];
    } else if (battery >= battery_min) {
        [_batteryIcon setImage: [UIImage imageNamed: @"ic_battery_one_bar"]];
    } else {
        [_batteryIcon setImage: [UIImage imageNamed: @"ic_no_battery"]];
    }
}

-(void)updateLableValues {
    if(controlstate==1) {
        [_btnConnectPluto setTitle:DISCONNECT_STATE forState:UIControlStateNormal];
        [_btnConnectPluto setTitleColor:[UIColor colorWithRed:18.0f/255.0f green:186.0f/255.0f blue:144.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        
        if(![Util isConnectedToPlutoWifi]) {
            [g_ManageServer setConnectType:CONNECT_NONE];
            [g_ManageServer setViewStatus:VIEW_State_RealPlay];
            [g_ManageServer setPreviewMode:1];
            [g_ManageServer setPlaybackStatus:false];
            [_ivPlayerView setHidden: NO];
            [self pemrmissionForAddingLibrary];
            
            [_btnCamera setUserInteractionEnabled: YES];
            [_btnVideo setUserInteractionEnabled: YES];
            [_btnLensFlip setUserInteractionEnabled: YES];
            [_cameraModuleView setAlpha: 1.0f];
        }
        
        controlstate=2;
    }
    
    [_rollValue setText:[NSString stringWithFormat:@"%i",roll]];
    [_pitchValue setText:[NSString stringWithFormat:@"%i",pitch]];
    [_yawValue setText:[NSString stringWithFormat:@"%i",yaw]];
    
    [self updateBatteryIcon];
    [_batteryValue setText:[[NSString stringWithFormat:@"%.01f",battery] stringByAppendingString:@" V"]];
    _armSwitch.userInteractionEnabled = YES;
    _armSwitch.alpha = 1.0f;
    [self updateFlightStatus];
    
    if(isArmed){
        int throttle = [remoteControl1 getThrottle];
        
        if (!isTimerStarted && throttle <= 1120) {
            [self startTimer];
            isTimerStarted = true;
        }
    }
}

-(void)initController {
    
    if(isArmed) {
        [_armSwitch setOn:TRUE];
    }
    else {
        [_armSwitch setOn:FALSE];
    }
    
    if(plutoManager.WiFiConnection.connected) {
        [_btnConnectPluto setTitle:DISCONNECT_STATE forState:UIControlStateNormal];
        [_btnConnectPluto setTitleColor:[UIColor colorWithRed:18.0f/255.0f green:186.0f/255.0f blue:144.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    }
    
    else {
        [_btnConnectPluto setTitle:CONNECT_STATE forState:UIControlStateNormal];
        [_btnConnectPluto setTitleColor:[UIColor colorWithRed:210.0f/255.0f green:17.0f/255.0f blue:95.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    }
    
    [_rollValue setText:@"--"];
    [_pitchValue setText:@"--"];
    [_yawValue setText:@"--"];
    [_batteryValue setText:@"- V"];
    
    storyboard = [UIStoryboard storyboardWithName:@"Graphs" bundle: nil];
    controlstate=0;
}

- (IBAction)goToSettings:(id)sender {
    
    if(plutoManager.WiFiConnection.connected && isArmed) {
        [self.view makeToast:@"Raven is in flying mode, can't access settings"];
    }
    else {
        STOP_RC_SIGNAL=TRUE;
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        vc = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
        
        if(self!=nil)
            [self presentViewController:vc animated:NO completion:nil];
    }
    
}

- (CMMotionManager *)motionManager {
    if (!_motionManager) {
        _motionManager = [CMMotionManager new];
        [_motionManager setDeviceMotionUpdateInterval:0.05];
    }
    return _motionManager;
}

- (CMMotionManager *)yawMotionManager {
    if (!_yawMotionManager) {
        _yawMotionManager = [CMMotionManager new];
        [_yawMotionManager setDeviceMotionUpdateInterval:0.05];
    }
    return _yawMotionManager;
}

-(CLLocationManager *)locationManager {
    if (!locationManager) {
        locationManager = [[CLLocationManager alloc] init];
    }
    return locationManager;
}

-(void) startRCSignalTimer{
    RCSignalTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                     target:self
                                                   selector:@selector(updateRc:)
                                                   userInfo:nil
                                                    repeats:YES];
    
    [NSTimer scheduledTimerWithTimeInterval:0.2
                                     target:self
                                   selector:@selector(updateLessFrequentData:)
                                   userInfo:nil
                                    repeats:YES];
    
}

-(void) updateRc: (NSTimer *)rcSignalTimer{
    if(!STOP_RC_SIGNAL){
        
        if(plutoManager.WiFiConnection.connected) {
            
            if(remoteControl1 !=nil && requests!=nil) {
                [plutoManager.protocol sendRequestMSP_RAW_RC:[remoteControl1 getRCSignals]];
                [plutoManager.protocol sendRequestMSP_DEBUG:requests];
            }
            
            if (NONE_COMMAND != commandType) {
                command_status = commandType == LAND ? 1 : 2;
                [plutoManager.protocol  sendRequestMSP_SET_COMMAND: commandType];
                commandType = NONE_COMMAND;
            }
            
            if ([[_btnConnectPluto titleForState:UIControlStateNormal] isEqualToString:LAND_STATE]) {
                if (command_status == 1) {
                    [plutoManager.protocol sendRequestMSP_GET_COMMAND];
                    
                    NSLog(@"command status: %d", command_status);
                } else if (command_status == 0 && current_command == LAND) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.armSwitch setOn:FALSE];
                        [self performDisarm];
                        self.armSwitch.userInteractionEnabled = NO;
                        self.armSwitch.alpha = 0.5f;
                    });
                }
            }
            
            [self performSelectorOnMainThread:@selector(updateLableValues) withObject:nil waitUntilDone:NO];
            
        }
        else if(controlstate == 2){
            [self performSelectorOnMainThread:@selector(disconnectPluto) withObject:nil waitUntilDone:YES];
        }
    }
}

-(void) updateLessFrequentData: (NSTimer *)rcSignalTimer {
    if(!STOP_RC_SIGNAL){
        if(plutoManager.WiFiConnection.connected) {
            
            if (nil == FLIGHT_CONTROLLER_ID)
                [plutoManager.protocol sendRequest_Firmware_VERSION];
            
            if (nil == BOARD_ID)
                [plutoManager.protocol sendRequestMSP_BOARD_INFO];
            
            [plutoManager.protocol sendRequestMSP_ATTITUDE];
            
            if (isDeveloperModeSensorOn)
                [plutoManager.protocol  sendRequest_Device_Heading: deviceYaw];
            
            if(isGPSModeOn)
                [plutoManager.protocol sendRequestMSP_SET_GPS:deviceLat and:deviceLong];
            
            [plutoManager.protocol sendReuestMSP_Analog];
        }
    }
}

-(void)startTimer {
    if(nil == flightTimeTimer && isArmed){
        
        if (isArmed && [[_btnConnectPluto titleForState:UIControlStateNormal] isEqualToString:TAKE_OFF_STATE]) {
            [_btnConnectPluto setEnabled:NO];
            _btnConnectPluto.alpha = 0.5f;
            _btnConnectPluto.userInteractionEnabled = NO;
            
            nsLandOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(landTask) object:nil];
            
            [nsOperationCommandQueue addOperation:nsLandOperation];
            
        }
        flightTimeSec = 0;
        flightTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(updateFlightTime:)
                                                         userInfo:nil
                                                          repeats:YES];
        [self startAnimation];
    }
}

-(void)stopTimer {
    [flightTimeTimer invalidate];
    flightTimeTimer = nil;
    isTimerPaused = true;
}

-(void) updateFlightTime:(NSTimer *)flightTimer {
    if (flightTimeSec >= 60) {
        int min = flightTimeSec / 60;
        int sec = flightTimeSec % 60;
        
        _timerMin.text = [@(min > 9 ? "" : "0") stringByAppendingString:@(min).stringValue];
        _timerSec.text = [@(sec > 9 ? "" : "0") stringByAppendingString:@(sec).stringValue];
        
    } else {
        _timerSec.text = [@(flightTimeSec > 9 ? "" : "0") stringByAppendingString:@(flightTimeSec).stringValue];
    }
    
    flightTimeSec++;
}

-(void) startAnimation{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionRepeat |UIViewAnimationOptionAutoreverse animations:^{
        self.timerMin.alpha = 0;
        self.timerSec.alpha = 0;
    } completion: nil];
}

-(void) removeAnimation{
    [_timerMin.layer removeAllAnimations];
    [_timerSec.layer removeAllAnimations];
    _timerMin.alpha = 1;
    _timerSec.alpha = 1;
}

-(void)swipeRight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if(plutoManager.WiFiConnection.connected && isArmed) {
        [self.view makeToast:@"Raven is in flying mode, can't access settings"];
    }
    else {
        STOP_RC_SIGNAL=TRUE;
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        vc = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
        
        if(self!=nil)
            [self presentViewController:vc animated:NO completion:nil];
    }
}

-(void)landTask {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 200 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        if(isArmed){
            [self.btnConnectPluto setTitle:LAND_STATE forState:UIControlStateNormal];
            [self.btnConnectPluto setTitleColor:[UIColor colorWithRed:18.0f/255.0f green:186.0f/255.0f blue:144.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [self.btnConnectPluto setEnabled:YES];
            self.btnConnectPluto.alpha = 1.0f;
            self.btnConnectPluto.userInteractionEnabled = YES;
        }
    });
}

- (IBAction)onAuxButtonClick:(id)sender {
    if(plutoManager.WiFiConnection.connected) {
        if (_auxType == DEVELOPER_MODE) {
            if ([remoteControl1 getRCSignal: remoteControl1->AUX2] == remoteControl1->RC_MID) {
                [remoteControl1 setMin: remoteControl1->AUX2];
                _btnAux.alpha = 0.5f;
            } else {
                [remoteControl1 setMid: remoteControl1->AUX2];
                _btnAux.alpha = 1.0f;
            }
        } else if (_btnAux.alpha == 1.0f) {
            commandType = BACK_FLIP;
            _btnAux.alpha = 0.5f;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1000 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                self.btnAux.alpha = 1.0f;
            });
        }
    }
}

-(void) auxLongPress {
    
    if(nil == auxDialogOptionUIView || !auxDialogOptionUIView.isAuxDialogViewOpen){
        auxDialogOptionUIView = [[AuxDialogOptionUIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        
        auxDialogOptionUIView.isAuxDialogViewOpen = true;
        [auxDialogOptionUIView setViewControllerAndAuxType:self and : _auxType == DEVELOPER_MODE ? YES : NO];
        [self.view addSubview:auxDialogOptionUIView];
    }
    
}

-(void) setAuxButtonStatus: (bool) isDevModeSelected {
    if(isDevModeSelected){
        [_btnAux setImage:[UIImage imageNamed:@"ic_developer_mode"] forState:UIControlStateNormal];
        _auxType = DEVELOPER_MODE;
        
        if ([remoteControl1 getRCSignal: remoteControl1->AUX2] == remoteControl1->RC_MID)
            _btnAux.alpha = 1.0f;
        else
            _btnAux.alpha = 0.5f;
        
        [_flipUnsupportLabel setHidden:YES];
        [preferences setBool:NO forKey:@"default_aux_mode"];
        
    } else {
        [_btnAux setImage:[UIImage imageNamed:@"ic_drone_flip"] forState:UIControlStateNormal];
        _auxType = FLIP_MODE;
        if(isArmed && !altholdOrThrottle){
            if(![Util isCurrentFirmwareMagis]){
                _btnAux.alpha = 0.5f;
                [_flipUnsupportLabel setHidden:NO];
            } else{
                _btnAux.alpha = 1.0f;
            }
        }
        else
            _btnAux.alpha = 0.5f;
        
        [preferences setBool:YES forKey:@"default_aux_mode"];
    }
    
}

-(void) getDeviceYawUpdates {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [self.yawMotionManager startDeviceMotionUpdatesToQueue:queue withHandler:^(CMDeviceMotion *motion, NSError *error) {
        
        int yaw = motion.attitude.yaw*57.2957795;
        if(yaw > 90)
            deviceYaw = 450 - yaw;
        else
            deviceYaw = 90 - yaw;
        
        int errorCorrection = 10;
        deviceYaw += errorCorrection;
        
        if(deviceYaw > 360) {
            deviceYaw -= 360;
        }
    }];
}

- (void) startLocationUpdates {
    
    CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
    
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager requestWhenInUseAuthorization];
            break;
            
        case kCLAuthorizationStatusRestricted: {
            UIAlertController *errorDialog = [UIAlertController alertControllerWithTitle:@"Error Message" message:@"You've been restricted from using te location service of this device, please contact the device owner." preferredStyle:UIAlertControllerStyleAlert];
            
            [errorDialog addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                [errorDialog dismissViewControllerAnimated:YES completion:nil];
            }]];
            
            [self presentViewController:errorDialog animated:YES completion:nil];
        }
            break;
            
        case kCLAuthorizationStatusDenied: {
            UIAlertController *alertDialog = [UIAlertController alertControllerWithTitle:@"To send GPS updates to Raven" message:@"Allow access to your location service to send GPS updates to Raven" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertDialog addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }]];
            
            [alertDialog addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
                [alertDialog dismissViewControllerAnimated:YES completion:nil];
            }]];
            
            [self presentViewController:alertDialog animated:YES completion:nil];
        }
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            if ([CLLocationManager locationServicesEnabled]) {
                self.locationManager.delegate = self;
            }
            else {
                [self.view makeToast:@"Enable location service to send GPS updates to Raven"];
            }
            break;
            
        default:
            break;
    }
}

+(RCSignals *)getRemoteController {
    return remoteControl1;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertController *alertDialog = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to Get GPS updates" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertDialog addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        [alertDialog dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alertDialog animated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            if ([CLLocationManager locationServicesEnabled]) {
                self.locationManager.delegate = self;
                locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                [locationManager startUpdatingLocation];
            }
            else {
                [self.view makeToast:@"Enable location service to send GPS updates to Raven"];
            }
            break;
            
        default:
            break;
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    CLLocation *currentLocation = locations.lastObject;
    
    if (currentLocation != nil) {
        deviceLat = currentLocation.coordinate.latitude * pow(10, 7);
        deviceLong = currentLocation.coordinate.longitude * pow(10, 7);
    }
}

#pragma mark WCSessionDelegate methods

#pragma mark Watch sessions

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message {
    if ((message[@"watchAccData"]) != nil) {
        // Incoming accelerometer data
        NSString *dataString = message[@"watchAccData"];
        NSArray *components = [dataString componentsSeparatedByString:@","];
        double x = [components[0] doubleValue];
        double y = [components[1] doubleValue];
        double z = [components[2] doubleValue];
        NSLog(@"X:%f Y:%f Z:%f",x,y,z);
        
    } else if (message[@"workoutState"]) {
        NSLog(@"New HKWorkoutSession state: %@",message[@"workoutState"]);
    } else if (message[@"error"]) {
        NSLog(@"Error: %@",message[@"error"]);
    }
}

-(void) gamingLogicTask {
    float totalFlightTime = gaming.totalFlightTime;
    totalFlightTime += round(1000*(float) flightTimeSec / 3600)/1000;
    float bestFlightTime = round(100*(float) flightTimeSec / 60)/100;
    
    int points, level;
    
    if (totalFlightTime < 0.42) {
        points = (int) ((totalFlightTime / 0.42f) * 50);
        level = 0;
    } else if (totalFlightTime < 2) {
        points = (int) [Util map:totalFlightTime and:0.42f and:2 and:50 and:100];
        level = 1;
    } else if (totalFlightTime < 3) {
        points = (int) [Util map:totalFlightTime and:2 and:3 and:0 and:50];
        level = 2;
    } else if (totalFlightTime < 5) {
        points = (int) [Util map:totalFlightTime and:3 and:5 and:50 and:100];
        level = 3;
    } else if (totalFlightTime < 15) {
        points = (int) [Util map:totalFlightTime and:5 and:15 and:0 and:50];
        level = 4;
    } else if (totalFlightTime < 27) {
        points = (int) [Util map:totalFlightTime and:15 and:27 and:50 and:100];
        level = 5;
    } else if (totalFlightTime < 35) {
        points = (int) [Util map:totalFlightTime and:27 and:35 and:0 and:50];
        level = 6;
    } else if (totalFlightTime < 45) {
        points = (int) [Util map:totalFlightTime and:35 and:45 and:50 and:100];
        level = 7;
    } else if (totalFlightTime < 60) {
        points = (int) [Util map:totalFlightTime and:45 and:60 and:0 and:50];
        level = 8;
    } else if (totalFlightTime <= 70) {
        points = (int) [Util map:totalFlightTime and:60 and:70 and:50 and:100];
        level = 9;
    } else {
        level = 9;
        points = 100;
    }
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    gaming.totalFlightTime = totalFlightTime;
    if(bestFlightTime > gaming.bestTime)
        gaming.bestTime = bestFlightTime;
    gaming.points = points;
    gaming.levelNo = level;
    [realm commitWriteTransaction];
}

- (void)didFinishSnap {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self->userSettings.isSounds){
            [self->audioPlayer play];
        }
        
        [self.view makeToast:@"Capture success"];
    });
}

-(void) startLocalRecord {
    if(userSettings.isSounds){
        [audioPlayer2 play];
    }
    
    [_btnVideo setImage:[UIImage imageNamed:@"ic_lewei_video_on"] forState:UIControlStateNormal];
    
    [_videoTimerContainer setHidden: NO];
}

-(void) stopLocalRecord {
    if(userSettings.isSounds){
        [audioPlayer2 play];
    }
    
    [_btnVideo setImage:[UIImage imageNamed:@"ic_lewei_video"] forState:UIControlStateNormal];
    
    [_videoTimerContainer setHidden: YES];
    _videoTimerLabel.text = @"00:00";
}

-(void) startCardRecord {
    if(userSettings.isSounds){
        [audioPlayer2 play];
    }
    
    [_btnVideo setImage:[UIImage imageNamed:@"ic_lewei_video_on"] forState:UIControlStateNormal];
    
    [_sdCardLabel setHidden: NO];
    [_videoTimerContainer setHidden: NO];
    recordSDSec = 0;
    recordSDTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self
                                                   selector:@selector(updateRecordSDTime:)
                                                   userInfo:nil
                                                    repeats:YES];
}

-(void) stopCardRecord {
    if(userSettings.isSounds){
        [audioPlayer2 play];
    }
    
    [_btnVideo setImage:[UIImage imageNamed:@"ic_lewei_video"] forState:UIControlStateNormal];
    
    [_sdCardLabel setHidden: YES];
    [_videoTimerContainer setHidden: YES];
    _videoTimerLabel.text = @"00:00";
    [recordSDTimer invalidate];
}

- (void)recordVideoTime:(int)second {
    
    NSString *minStr, *secStr;
    
    if (second >= 60) {
        int min = second / 60;
        int sec = second % 60;
        
        minStr = [@(min > 9 ? "" : "0") stringByAppendingString:@(min).stringValue];
        secStr = [@(sec > 9 ? ":" : ":0") stringByAppendingString:@(sec).stringValue];
        
    } else {
        minStr = @"00";
        secStr = [@(second > 9 ? ":" : ":0") stringByAppendingString:@(second).stringValue];
    }
    
    _videoTimerLabel.text = [minStr stringByAppendingString: secStr];
}

-(void)updateRecordSDTime:(NSTimer *)recordSDTimer {
    [self recordVideoTime: recordSDSec];
    recordSDSec ++;
}

-(void)pemrmissionForAddingLibrary {
    UIImageWriteToSavedPhotosAlbum([UIImage imageNamed:@"temp"], nil, nil, nil);
}

-(void)performDisarm {
    if(isArmed) {
        [remoteControl1 setMin: remoteControl1->AUX4];
        isArmed=FALSE;
        [self stopTimer];
        isTimerStarted = false;
        [self removeAnimation];
        
        [_btnConnectPluto setTitle:DISCONNECT_STATE forState:UIControlStateNormal];
        [_btnConnectPluto setTitleColor:[UIColor colorWithRed:18.0f/255.0f green:186.0f/255.0f blue:144.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [_btnConnectPluto setEnabled:YES];
        _btnConnectPluto.alpha = 1.0f;
        _btnConnectPluto.userInteractionEnabled = YES;
        
        if(_auxType == FLIP_MODE)
            _btnAux.alpha = 0.5f;
        
        [_flipUnsupportLabel setHidden:YES];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

@end
