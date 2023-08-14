//
//  ChangeWifiController.m
//  PlutoController
//
//  Created by Drona Aviation on 22/11/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "ChangeWifiController.h"
#import "Config.h"
#import "LWManage.h"
#import "Util.h"
#import <SystemConfiguration/CaptiveNetwork.h>

#define kOFFSET_FOR_KEYBOARD 72.0

@interface ChangeWifiController ()

@property (weak, nonatomic) IBOutlet UIView *swipeView;
@property (weak, nonatomic) IBOutlet UIButton *btnApplySave;
@property (weak, nonatomic) IBOutlet UITextField *tfNewWifi;
@property (weak, nonatomic) IBOutlet UITextField *tfCurrentPwd;
@property (weak, nonatomic) IBOutlet UILabel *pwdErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *wifiErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentWifiLabel;

@end

@implementation ChangeWifiController

NSMutableString *wifiPrefix;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _btnApplySave.layer.cornerRadius = 20;
    _btnApplySave.clipsToBounds = YES;
    [_btnApplySave.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnApplySave layer] setBorderWidth:5.0f];
    [_btnApplySave setTitleColor:[UIColor colorWithRed:18.0f/255.0f green:186.0f/255.0f blue:144.0f/255.0f alpha:1.0f] forState:UIControlStateSelected];
    _btnApplySave.userInteractionEnabled = NO;
    
    _tfNewWifi.layer.masksToBounds = YES;
    _tfNewWifi.layer.borderColor = [[UIColor whiteColor]CGColor];
    _tfNewWifi.layer.borderWidth = 1.0f;
    _tfNewWifi.autocorrectionType = UITextAutocorrectionTypeNo;
    
    _tfCurrentPwd.layer.masksToBounds = YES;
    _tfCurrentPwd.layer.borderColor = [[UIColor whiteColor]CGColor];
    _tfCurrentPwd.layer.borderWidth = 1.0f;
    _tfCurrentPwd.autocorrectionType = UITextAutocorrectionTypeNo;
    
    if([Util droneType:[NSUserDefaults standardUserDefaults]] == 1) {
        wifiPrefix = [NSMutableString stringWithString:@"PlutoX_"];
    } else {
        wifiPrefix = [NSMutableString stringWithString:@"Pluto_"];
    }
    
    if(![Util isConnectedToPlutoWifi])
        [wifiPrefix appendFormat:@"%@", @"Cam_"];
    
    UILabel *plusLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    plusLabel.text = [NSString stringWithFormat:@"%@%@", @" ", wifiPrefix];;
    plusLabel.textColor = [UIColor whiteColor];
    [plusLabel sizeToFit];
    
    _tfNewWifi.leftView = plusLabel;
    _tfNewWifi.leftViewMode = UITextFieldViewModeAlways;
    
    _tfNewWifi.delegate = self;
    _tfCurrentPwd.delegate = self;
    
    NSDictionary *ssidInfo = [self fetchSSIDInfo];
    _currentWifiLabel.text = ssidInfo[@"SSID"];
    
    UISwipeGestureRecognizer * swipeRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
    [_swipeView addGestureRecognizer:swipeRight];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if(textField == _tfCurrentPwd) {
        textField.layer.borderColor = [[UIColor whiteColor]CGColor];
        [_pwdErrorLabel setHidden:YES];
    } else if(textField == _tfNewWifi) {
        textField.layer.borderColor = [[UIColor whiteColor]CGColor];
        [_wifiErrorLabel setHidden:YES];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    _btnApplySave.alpha = 1.0f;
    _btnApplySave.userInteractionEnabled = YES;
    
    if(textField == _tfNewWifi) {
        [_tfCurrentPwd becomeFirstResponder];
        if(textField.text.length == 0) {
            textField.layer.borderColor = [[UIColor redColor]CGColor];
            [_wifiErrorLabel setHidden:NO];
        }
    }
    
    else if(textField == _tfCurrentPwd) {
        [_tfCurrentPwd resignFirstResponder];
        if(textField.text.length <= 7){
            textField.layer.borderColor = [[UIColor redColor]CGColor];
            [_pwdErrorLabel setHidden:NO];
        }
    }
    
    if(_tfNewWifi.text.length ==0 || _tfCurrentPwd.text.length <= 7) {
        _btnApplySave.alpha = 0.5f;
        _btnApplySave.userInteractionEnabled = NO;
    }
    
    return YES;
}

- (IBAction)applyAndSaveClicked:(id)sender {
    if(plutoManager.WiFiConnection.connected) {
        
        NSString *ssid=[wifiPrefix stringByAppendingString: _tfNewWifi.text];
        NSString *currentPwd = [_tfCurrentPwd text];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if([Util isConnectedToPlutoWifi]) {
                [plutoManager.protocol sendRequestAT_WIFI_SETTINGS: ssid withPassword:currentPwd withChannel: arc4random() % (13 - 1) + 1];
            }
            else {
                LWManage *g_ManageServer = [Util sharedLeweiLib: nil];
                if(nil != g_ManageServer) {
                    [g_ManageServer wifiSsid: (char*)[ssid UTF8String]];
                   [g_ManageServer wifiPassword: (char*)[currentPwd UTF8String]];
                    [g_ManageServer wifiChannel: arc4random() % (13 - 1) + 1];
                    [g_ManageServer deviceReboot];
                }
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 200 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                [self.view makeToast:@"WiFi Settings Updated Successfully, Please Reconnect Raven"];

                plutoManager.WiFiConnection.connected=FALSE;

                [self dismissViewControllerAnimated:YES completion:nil];
            });
        });
    }
}

- (IBAction)BackToController:(id)sender {
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

-(void)swipeRight:(UISwipeGestureRecognizer*)gestureRecognizer {
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

-(void)keyboardWasShown:(NSNotification*)notification {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        // [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillBeHidden:(NSNotification*)notification {
    if (self.view.frame.origin.y >= 0)
        [self setViewMovedUp:YES];
    
    else if (self.view.frame.origin.y < 0)
        [self setViewMovedUp:NO];
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp) {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

- (NSDictionary *)fetchSSIDInfo {
    NSArray *interfaceNames = (__bridge_transfer id)(CNCopySupportedInterfaces());
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName);
        
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty)
            break;
    }
    
    return SSIDInfo;
}

@end
