//
//  DroneViewController.m
//  PlutoController
//
//  Created by Drona Aviation on 08/05/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Realm/Realm.h"
#import "User.h"
#import "Config.h"
#import "Util.h"
#import "AccCalibrationDialogUIView.h"
#import "MagCalibrationDialogUIView.h"
#import "CustomProgressView.h"
#import "RecoverPwdDialogView.h"
#import "DroneViewController.h"

@interface DroneViewController()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *swipeView;

@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIButton *btnCalibration;

@property (weak, nonatomic) IBOutlet UIButton *btnRollSubtract;
@property (weak, nonatomic) IBOutlet UIButton *btnPitchSubtract;
@property (weak, nonatomic) IBOutlet UIButton *btnRollAdd;
@property (weak, nonatomic) IBOutlet UIButton *btnPitchAdd;

@property (weak, nonatomic) IBOutlet UIButton *btnM1;
@property (weak, nonatomic) IBOutlet UIButton *btnM2;
@property (weak, nonatomic) IBOutlet UIButton *btnM3;
@property (weak, nonatomic) IBOutlet UIButton *btnM4;
@property (weak, nonatomic) IBOutlet UIButton *btnSpinAll;
@property (weak, nonatomic) IBOutlet UIButton *btnSensorGraph;
@property (weak, nonatomic) IBOutlet UIButton *btnPID;
@property (weak, nonatomic) IBOutlet UIButton *btnChangeWifiName;
@property (weak, nonatomic) IBOutlet UIButton *btnChangeWifiPwd;

@property (weak, nonatomic) IBOutlet UITextField *textFieldRoll;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPitch;

@property (weak, nonatomic) IBOutlet UILabel *uiLabelCalibration;

@property (weak, nonatomic) IBOutlet UISegmentedControl *scAccMag;

@end

@implementation DroneViewController

CAShapeLayer *maskLayerWhiteRightDvc;
CAShapeLayer *borderLayerWhiteRightDvc;

CAShapeLayer *maskLayerWhiteLeftDvc;
CAShapeLayer *borderLayerWhiteLeftDvc;

int motors_speed[8];
int rollPitchMax = 1000;
int rollPitchMin = -1000;
int trimStepValue = 1;
int initialTrimValue = 2000;
int currentRollValue;
int currentPitchValue;

bool isAccCalibrationSelected;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [self initMembers];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [UIFont boldSystemFontOfSize:13.0f],
                                 NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    [_scAccMag setTitleTextAttributes:attributes
                             forState:UIControlStateSelected];
    [_scAccMag setTitleTextAttributes:attributes
                             forState:UIControlStateNormal];
    
    _scAccMag.subviews[1].layer.mask = maskLayerWhiteRightDvc;
    [[_scAccMag.subviews[1] layer] addSublayer:borderLayerWhiteRightDvc];
    _scAccMag.subviews[0].layer.mask = maskLayerWhiteLeftDvc;
    [[_scAccMag.subviews[0] layer] addSublayer:borderLayerWhiteLeftDvc];
    
    _btnCalibration.layer.cornerRadius = 3;
    _btnCalibration.clipsToBounds = YES;
    [_btnCalibration.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [[_btnCalibration layer] setBorderWidth:1.0f];
    
    _btnRollSubtract.layer.cornerRadius = 14;
    _btnRollSubtract.clipsToBounds = YES;
    [_btnRollSubtract.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnRollSubtract layer] setBorderWidth:4.0f];
    
    _btnRollAdd.layer.cornerRadius = 14;
    _btnRollAdd.clipsToBounds = YES;
    [_btnRollAdd.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnRollAdd layer] setBorderWidth:4.0f];
    
    _btnPitchSubtract.layer.cornerRadius = 14;
    _btnPitchSubtract.clipsToBounds = YES;
    [_btnPitchSubtract.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnPitchSubtract layer] setBorderWidth:4.0f];
    
    _btnPitchAdd.layer.cornerRadius = 14;
    _btnPitchAdd.clipsToBounds = YES;
    [_btnPitchAdd.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnPitchAdd layer] setBorderWidth:4.0f];
    
    _btnM4.layer.cornerRadius = 20;
    _btnM4.clipsToBounds = YES;
    [_btnM4.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnM4 layer] setBorderWidth:5.0f];
    [_btnM4 setTitleColor:[UIColor colorWithRed:18.0f/255.0f green:186.0f/255.0f blue:144.0f/255.0f alpha:1.0f] forState:UIControlStateSelected];
    
    _btnM2.layer.cornerRadius = 20;
    _btnM2.clipsToBounds = YES;
    [_btnM2.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnM2 layer] setBorderWidth:5.0f];
    [_btnM2 setTitleColor:[UIColor colorWithRed:18.0f/255.0f green:186.0f/255.0f blue:144.0f/255.0f alpha:1.0f] forState:UIControlStateSelected];
    
    _btnM3.layer.cornerRadius = 20;
    _btnM3.clipsToBounds = YES;
    [_btnM3.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnM3 layer] setBorderWidth:5.0f];
    [_btnM3 setTitleColor:[UIColor colorWithRed:18.0f/255.0f green:186.0f/255.0f blue:144.0f/255.0f alpha:1.0f] forState:UIControlStateSelected];
    
    _btnM1.layer.cornerRadius = 20;
    _btnM1.clipsToBounds = YES;
    [_btnM1.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnM1 layer] setBorderWidth:5.0f];
    [_btnM1 setTitleColor:[UIColor colorWithRed:18.0f/255.0f green:186.0f/255.0f blue:144.0f/255.0f alpha:1.0f] forState:UIControlStateSelected];
    
    _btnSpinAll.layer.cornerRadius = 20;
    _btnSpinAll.clipsToBounds = YES;
    [_btnSpinAll.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnSpinAll layer] setBorderWidth:5.0f];
    [_btnSpinAll setTitleColor:[UIColor colorWithRed:18.0f/255.0f green:186.0f/255.0f blue:144.0f/255.0f alpha:1.0f] forState:UIControlStateSelected];
    
    _btnSensorGraph.layer.cornerRadius = 20;
    _btnSensorGraph.clipsToBounds = YES;
    [_btnSensorGraph.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnSensorGraph layer] setBorderWidth:5.0f];
    
    _btnPID.layer.cornerRadius = 20;
    _btnPID.clipsToBounds = YES;
    [_btnPID.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnPID layer] setBorderWidth:5.0f];
    
    if([Util droneType:[NSUserDefaults standardUserDefaults]] != 0) {
        [_btnM1 setTitle:@"M7" forState:UIControlStateNormal];
        [_btnM2 setTitle:@"M8" forState:UIControlStateNormal];
        [_btnM3 setTitle:@"M6" forState:UIControlStateNormal];
        [_btnM4 setTitle:@"M5" forState:UIControlStateNormal];
    }
    
    _btnChangeWifiName.layer.cornerRadius = 20;
    _btnChangeWifiName.clipsToBounds = YES;
    [_btnChangeWifiName.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnChangeWifiName layer] setBorderWidth:5.0f];
    
    _btnChangeWifiPwd.layer.cornerRadius = 20;
    _btnChangeWifiPwd.clipsToBounds = YES;
    [_btnChangeWifiPwd.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnChangeWifiPwd layer] setBorderWidth:5.0f];
    
    UIToolbar* rollNumberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    rollNumberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(rollCancelNumberPad)],
                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(rollDoneWithNumberPad)]];
    [rollNumberToolbar sizeToFit];
    
    UIToolbar* pitchNumberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    pitchNumberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(pitchCancelNumberPad)],
                                 [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                 [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(pitchDoneWithNumberPad)]];
    [pitchNumberToolbar sizeToFit];
    
    _textFieldRoll.inputAccessoryView = rollNumberToolbar;
    _textFieldPitch.inputAccessoryView= pitchNumberToolbar;
    
    currentRollValue = initialTrimValue;
    currentPitchValue = initialTrimValue;
    
    if(plutoManager.WiFiConnection.connected) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [plutoManager.protocol sendRequestMSP_ACC_TRIM];
            
            usleep(100000);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.textFieldRoll setText:[NSString stringWithFormat:@"%d",trim_roll]];
                
                [self.textFieldPitch setText:[NSString stringWithFormat:@"%d",trim_pitch]];
            });
            
        });
    }
    
    RLMResults<User *> *users = [User objectsWhere:@"userId = 'PLUTO_DEFAULT_USER'"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"userId = %@",
                         @"PLUTO_DEFAULT_USER"];
    users = [User objectsWithPredicate:pred];
    
    RLMResults<UserSettings *> *userSettings = [UserSettings objectsWhere:@"ANY user = %@", users[0]];
    pred = [NSPredicate predicateWithFormat:@"ANY user = %@",
            users[0]];
    userSettings = [UserSettings objectsWithPredicate:pred];
    currentUserSettings = userSettings[0];
    
    NSString *path = [NSString stringWithFormat:@"%@/error_sound.wav", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    
    UISwipeGestureRecognizer * swipeRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
    [_swipeView addGestureRecognizer:swipeRight];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [_btnM1 setSelected:false];
    [_btnM2 setSelected:false];
    [_btnM3 setSelected:false];
    [_btnM4 setSelected:false];
    [_btnSpinAll setSelected:false];
    
    motors_speed[0] = 1000;
    motors_speed[1] = 1000;
    motors_speed[2] = 1000;
    motors_speed[3] = 1000;
    motors_speed[4] = 1000;
    motors_speed[5] = 1000;
    motors_speed[6] = 1000;
    motors_speed[7] = 1000;
    
    if(plutoManager.WiFiConnection.connected){
        [plutoManager.protocol sendRequestMSP_SET_MOTOR:motors_speed];
        
        if (currentRollValue != initialTrimValue || currentPitchValue != initialTrimValue) {
            trim_roll = currentRollValue == initialTrimValue ? trim_roll : currentRollValue;
            trim_pitch = currentPitchValue == initialTrimValue ? trim_pitch : currentPitchValue;
            isTrimSet = true;
        }
    }
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    
}

- (IBAction)BackToController:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)motorM1:(id)sender {
    
    if(!_btnM1.isSelected) {
        motors_speed[0] = 1200;
        motors_speed[1] = 1000;
        motors_speed[2] = 1000;
        motors_speed[3] = 1000;
        motors_speed[4] = 1000;
        motors_speed[5] = 1000;
        motors_speed[6] = 1000;
        motors_speed[7] = 1000;
        
        [_btnM1 setSelected:true];
        [_btnM2 setSelected:false];
        [_btnM3 setSelected:false];
        [_btnM4 setSelected:false];
        [_btnSpinAll setSelected:false];
    }
    else {
        motors_speed[0] = 1000;
        motors_speed[1] = 1000;
        motors_speed[2] = 1000;
        motors_speed[3] = 1000;
        motors_speed[4] = 1000;
        motors_speed[5] = 1000;
        motors_speed[6] = 1000;
        motors_speed[7] = 1000;
        
        [_btnM1 setSelected:false];
    }
    
    if(plutoManager.WiFiConnection.connected)
        [plutoManager.protocol sendRequestMSP_SET_MOTOR:motors_speed];
    
}

- (IBAction)motorM2:(id)sender {
    if(!_btnM2.isSelected) {
        motors_speed[0] = 1000;
        motors_speed[1] = 1200;
        motors_speed[2] = 1000;
        motors_speed[3] = 1000;
        motors_speed[4] = 1000;
        motors_speed[5] = 1000;
        motors_speed[6] = 1000;
        motors_speed[7] = 1000;
        
        [_btnM1 setSelected:false];
        [_btnM2 setSelected:true];
        [_btnM3 setSelected:false];
        [_btnM4 setSelected:false];
        [_btnSpinAll setSelected:false];
    }
    else {
        motors_speed[0] = 1000;
        motors_speed[1] = 1000;
        motors_speed[2] = 1000;
        motors_speed[3] = 1000;
        motors_speed[4] = 1000;
        motors_speed[5] = 1000;
        motors_speed[6] = 1000;
        motors_speed[7] = 1000;
        
        [_btnM2 setSelected:false];
    }
    
    if(plutoManager.WiFiConnection.connected)
        [plutoManager.protocol sendRequestMSP_SET_MOTOR:motors_speed];
}

- (IBAction)motorM3:(id)sender {
    if(!_btnM3.isSelected) {
        motors_speed[0] = 1000;
        motors_speed[1] = 1000;
        motors_speed[2] = 1200;
        motors_speed[3] = 1000;
        motors_speed[4] = 1000;
        motors_speed[5] = 1000;
        motors_speed[6] = 1000;
        motors_speed[7] = 1000;
        
        [_btnM1 setSelected:false];
        [_btnM2 setSelected:false];
        [_btnM3 setSelected:true];
        [_btnM4 setSelected:false];
        [_btnSpinAll setSelected:false];
    }
    else {
        motors_speed[0] = 1000;
        motors_speed[1] = 1000;
        motors_speed[2] = 1000;
        motors_speed[3] = 1000;
        motors_speed[4] = 1000;
        motors_speed[5] = 1000;
        motors_speed[6] = 1000;
        motors_speed[7] = 1000;
        
        [_btnM3 setSelected:false];
    }
    
    if(plutoManager.WiFiConnection.connected)
        [plutoManager.protocol sendRequestMSP_SET_MOTOR:motors_speed];
}

- (IBAction)motorM4:(id)sender {
    if(!_btnM4.isSelected) {
        motors_speed[0] = 1000;
        motors_speed[1] = 1000;
        motors_speed[2] = 1000;
        motors_speed[3] = 1200;
        motors_speed[4] = 1000;
        motors_speed[5] = 1000;
        motors_speed[6] = 1000;
        motors_speed[7] = 1000;
        
        [_btnM1 setSelected:false];
        [_btnM2 setSelected:false];
        [_btnM3 setSelected:false];
        [_btnM4 setSelected:true];
        [_btnSpinAll setSelected:false];
    }
    else {
        motors_speed[0] = 1000;
        motors_speed[1] = 1000;
        motors_speed[2] = 1000;
        motors_speed[3] = 1000;
        motors_speed[4] = 1000;
        motors_speed[5] = 1000;
        motors_speed[6] = 1000;
        motors_speed[7] = 1000;
        
        [_btnM4 setSelected:false];
    }
    
    if(plutoManager.WiFiConnection.connected)
        [plutoManager.protocol sendRequestMSP_SET_MOTOR:motors_speed];
}

- (IBAction)motorAll:(id)sender {
    if(!_btnSpinAll.isSelected) {
        motors_speed[0] = 1200;
        motors_speed[1] = 1200;
        motors_speed[2] = 1200;
        motors_speed[3] = 1200;
        motors_speed[4] = 1200;
        motors_speed[5] = 1200;
        motors_speed[6] = 1200;
        motors_speed[7] = 1200;
        
        [_btnM1 setSelected:false];
        [_btnM2 setSelected:false];
        [_btnM3 setSelected:false];
        [_btnM4 setSelected:false];
        [_btnSpinAll setSelected:true];
    }
    else {
        motors_speed[0] = 1000;
        motors_speed[1] = 1000;
        motors_speed[2] = 1000;
        motors_speed[3] = 1000;
        motors_speed[4] = 1000;
        motors_speed[5] = 1000;
        motors_speed[6] = 1000;
        motors_speed[7] = 1000;
        
        [_btnSpinAll setSelected:false];
    }
    
    if(plutoManager.WiFiConnection.connected)
        [plutoManager.protocol sendRequestMSP_SET_MOTOR:motors_speed];
}

-(void)rollCancelNumberPad{
    [_textFieldRoll resignFirstResponder];
    [_textFieldRoll setText:[NSString stringWithFormat:@"%d", plutoManager.WiFiConnection.connected ?trim_roll : 0]];
    currentRollValue = trim_roll;
}

-(void)rollDoneWithNumberPad{
    [_textFieldRoll resignFirstResponder];
}

-(void)pitchCancelNumberPad{
    [_textFieldPitch resignFirstResponder];
    [_textFieldPitch setText:[NSString stringWithFormat:@"%d",plutoManager.WiFiConnection.connected ?trim_pitch : 0]];
    currentPitchValue = trim_pitch;
}

-(void)pitchDoneWithNumberPad{
    [_textFieldPitch resignFirstResponder];
}

- (void)keyboardWasShown:(NSNotification*)notification
{
    NSDictionary *info = [notification userInfo];
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    UIEdgeInsets contentInset = self.scrollView.contentInset;
    contentInset.bottom = keyboardRect.size.height;
    self.scrollView.contentInset = contentInset;
}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
}

- (IBAction)rollInputDone:(UITextField *)sender {
    
    NSString *rollValueString=[sender text];
    
    int rollValue=[rollValueString intValue];
    
    if (rollValue>rollPitchMax) {
        rollValue=rollPitchMax;
    }
    
    else if (rollValue<rollPitchMin) {
        rollValue=rollPitchMin;
    }
    
    [_textFieldRoll setText:[NSString stringWithFormat:@"%d",rollValue]];
    currentRollValue = rollValue;
}

- (IBAction)pitchInputDone:(UITextField *)sender {
    
    NSString *pitchValueString=[sender text];
    
    int pitchValue=[pitchValueString intValue];
    
    if (pitchValue>1000) {
        pitchValue=1000;
    }
    
    else if (pitchValue<-1000) {
        pitchValue=-1000;
    }
    
    [_textFieldPitch setText:[NSString stringWithFormat:@"%d",pitchValue]];
    currentPitchValue = pitchValue;
}

- (IBAction)btnRollAddOnClick:(id)sender {
    int rollValue=[_textFieldRoll.text intValue] + trimStepValue;
    
    if (rollValue>rollPitchMax) {
        rollValue=rollPitchMax;
    }
    
    else if (rollValue<rollPitchMin) {
        rollValue=rollPitchMin;
    }
    
    [_textFieldRoll setText:[NSString stringWithFormat:@"%d",rollValue]];
    currentRollValue = rollValue;
}

- (IBAction)btnRollSubtractOnClick:(id)sender {
    int rollValue=[_textFieldRoll.text intValue] - trimStepValue;
    
    if (rollValue>rollPitchMax) {
        rollValue=rollPitchMax;
    }
    
    else if (rollValue<rollPitchMin) {
        rollValue=rollPitchMin;
    }
    
    [_textFieldRoll setText:[NSString stringWithFormat:@"%d",rollValue]];
    currentRollValue = rollValue;
}

- (IBAction)btnPitchAddOnClick:(id)sender {
    int pitchValue=[_textFieldPitch.text intValue] + trimStepValue;
    
    if (pitchValue>rollPitchMax) {
        pitchValue=rollPitchMax;
    }
    
    else if (pitchValue<rollPitchMin) {
        pitchValue=rollPitchMin;
    }
    
    [_textFieldPitch setText:[NSString stringWithFormat:@"%d",pitchValue]];
    currentPitchValue = pitchValue;
}

- (IBAction)btnPitchSubtractOnClick:(id)sender {
    int pitchValue=[_textFieldPitch.text intValue] - trimStepValue;
    
    if (pitchValue>rollPitchMax) {
        pitchValue=rollPitchMax;
    }
    
    else if (pitchValue<rollPitchMin) {
        pitchValue=rollPitchMin;
    }
    
    [_textFieldPitch setText:[NSString stringWithFormat:@"%d",pitchValue]];
    currentPitchValue = pitchValue;
}

- (IBAction)scAccMagValueChanged:(id)sender {
    
    switch (_scAccMag.selectedSegmentIndex) {
        case 0:
            isAccCalibrationSelected = true;
            [_uiLabelCalibration setText:@"To keep Raven stable as it flies"];
            break;
            
        case 1:
            isAccCalibrationSelected = false;
            [_uiLabelCalibration setText:@"To maintain Raven heading accurately"];
            break;
            
        default:
            break;
    }
}

- (IBAction)showCalibrationDialog:(id)sender {
    if(plutoManager.WiFiConnection.connected) {
        
        if(isAccCalibrationSelected) {
            AccCalibrationDialogUIView *accCalibrationDialogView = [[AccCalibrationDialogUIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            
            [(CustomProgressView *)accCalibrationDialogView.calibrationProgressView setGradient];
            [self.view addSubview:accCalibrationDialogView];
            [plutoManager.protocol sendRequestMSP_ACC_CALIBRATION];
        }
        
        else {
            MagCalibrationDialogUIView *magCalibrationDialogView = [[MagCalibrationDialogUIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            
            [(CustomProgressView *)magCalibrationDialogView.magCalibrationProgressView setGradient];
            [self.view addSubview:magCalibrationDialogView];
            [plutoManager.protocol sendRequestMSP_MAG_CALIBRATION];
        }
        
    }
    
    else {
        if(currentUserSettings.isSounds){
            [audioPlayer play];
        }
        [self.view makeToast:@"Raven isn't connected"];
    }
}

- (IBAction)changeWifiNameClicked:(id)sender {
    
    if(plutoManager.WiFiConnection.connected) {
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangeWifi"];
        [self addChildViewController:vc];
        [self.view addSubview:vc.view];
        [vc didMoveToParentViewController:self];
    }
    else {
        if(currentUserSettings.isSounds){
            [audioPlayer play];
        }
        [self.view makeToast:@"Raven isn't connected"];
    }
    
}

- (IBAction)changeWifiPwdClicked:(id)sender {
    if(plutoManager.WiFiConnection.connected) {
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePwd"];
        [self addChildViewController:vc];
        [self.view addSubview:vc.view];
        [vc didMoveToParentViewController:self];
    }
    else {
        if(currentUserSettings.isSounds){
            [audioPlayer play];
        }
        [self.view makeToast:@"Raven isn't connected"];
    }
}

- (IBAction)recoverPwdClicked:(id)sender {
    RecoverPwdDialogView *recoverPwdDialog = [[RecoverPwdDialogView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [self.view addSubview: recoverPwdDialog];
}

-(void) initMembers {
    CGRect outline = CGRectMake(_scAccMag.bounds.origin.x, _scAccMag.bounds.origin.y, _scAccMag.bounds.size.width * 0.5f, _scAccMag.bounds.size.height);
    
    maskLayerWhiteRightDvc = [CAShapeLayer layer];
    maskLayerWhiteRightDvc.path = [UIBezierPath bezierPathWithRoundedRect: outline byRoundingCorners: UIRectCornerTopRight | UIRectCornerBottomRight  cornerRadii: CGSizeMake(20, 20)].CGPath;
    
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect: outline byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(20, 20)];
    borderLayerWhiteRightDvc = [CAShapeLayer layer];
    borderLayerWhiteRightDvc.frame       = _scAccMag.subviews[0].bounds;
    borderLayerWhiteRightDvc.path        = borderPath.CGPath;
    borderLayerWhiteRightDvc.strokeColor = [UIColor whiteColor].CGColor;
    borderLayerWhiteRightDvc.fillColor   = [UIColor clearColor].CGColor;
    borderLayerWhiteRightDvc.lineWidth   = 2.0f;
    
    maskLayerWhiteLeftDvc = [CAShapeLayer layer];
    maskLayerWhiteLeftDvc.path = [UIBezierPath bezierPathWithRoundedRect: outline byRoundingCorners: UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii: CGSizeMake(20, 20)].CGPath;
    UIBezierPath *borderPath1 = [UIBezierPath bezierPathWithRoundedRect: outline byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(20, 20)];
    borderLayerWhiteLeftDvc = [CAShapeLayer layer];
    borderLayerWhiteLeftDvc.frame       = _scAccMag.subviews[0].bounds;
    borderLayerWhiteLeftDvc.path        = borderPath1.CGPath;
    borderLayerWhiteLeftDvc.strokeColor = [UIColor whiteColor].CGColor;
    borderLayerWhiteLeftDvc.fillColor   = [UIColor clearColor].CGColor;
    borderLayerWhiteLeftDvc.lineWidth   = 2.0f;
    
    isAccCalibrationSelected = true;
}

-(void)swipeRight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

