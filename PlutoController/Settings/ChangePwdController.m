//
//  ChangePwdController.m
//  PlutoController
//
//  Created by Drona Aviation on 28/11/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "ChangePwdController.h"
#import "Config.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Realm/Realm.h"

#define kOFFSET_FOR_KEYBOARD 72.0

@interface ChangePwdController ()

@property (weak, nonatomic) IBOutlet UIView *swipeView;
@property (weak, nonatomic) IBOutlet UIButton *btnApplySave;
@property (weak, nonatomic) IBOutlet UIButton *btnVisibility;
@property (weak, nonatomic) IBOutlet UITextField *tfNewPwd;
@property (weak, nonatomic) IBOutlet UITextField *tfConfirmPwd;
@property (weak, nonatomic) IBOutlet UILabel *labelnewPwd;
@property (weak, nonatomic) IBOutlet UILabel *labelConfirmPwd;

@end

@implementation ChangePwdController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    realm = [RLMRealm defaultRealm];
    
    _btnApplySave.layer.cornerRadius = 20;
    _btnApplySave.clipsToBounds = YES;
    [_btnApplySave.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnApplySave layer] setBorderWidth:5.0f];
    [_btnApplySave setTitleColor:[UIColor colorWithRed:18.0f/255.0f green:186.0f/255.0f blue:144.0f/255.0f alpha:1.0f] forState:UIControlStateSelected];
    _btnApplySave.userInteractionEnabled = NO;
    
    _tfNewPwd.layer.masksToBounds = YES;
    _tfNewPwd.layer.borderColor = [[UIColor whiteColor]CGColor];
    _tfNewPwd.layer.borderWidth = 1.0f;
    _tfNewPwd.autocorrectionType = UITextAutocorrectionTypeNo;
    
    _tfConfirmPwd.layer.masksToBounds = YES;
    _tfConfirmPwd.layer.borderColor = [[UIColor whiteColor]CGColor];
    _tfConfirmPwd.layer.borderWidth = 1.0f;
    _tfConfirmPwd.autocorrectionType = UITextAutocorrectionTypeNo;
    
    _tfNewPwd.delegate = self;
    _tfConfirmPwd.delegate = self;

    UISwipeGestureRecognizer *swipeRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
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
    if(textField == _tfNewPwd) {
        textField.layer.borderColor = [[UIColor whiteColor]CGColor];
        [_labelnewPwd setHidden:YES];
    } else if(textField == _tfConfirmPwd) {
        textField.layer.borderColor = [[UIColor whiteColor]CGColor];
        [_labelConfirmPwd setHidden:YES];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    _btnApplySave.alpha = 1.0f;
    _btnApplySave.userInteractionEnabled = YES;
    
    if(textField == _tfNewPwd) {
        [_tfConfirmPwd becomeFirstResponder];
        if(textField.text.length <= 7) {
            textField.layer.borderColor = [[UIColor redColor]CGColor];
            [_labelnewPwd setHidden:NO];
        }
    }
    
    else if(textField == _tfConfirmPwd) {
        [_tfConfirmPwd resignFirstResponder];
        if(textField.text != _tfNewPwd.text){
            textField.layer.borderColor = [[UIColor redColor]CGColor];
            [_labelConfirmPwd setHidden:NO];
        }
    }
    
    if(_tfConfirmPwd.text != _tfNewPwd.text || _tfNewPwd.text.length <= 7) {
        _btnApplySave.alpha = 0.5f;
        _btnApplySave.userInteractionEnabled = NO;
    }
    
    return YES;
}

- (IBAction)BackToController:(id)sender {
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (IBAction)applyAndSaveClicked:(id)sender {
    if(plutoManager.WiFiConnection.connected) {
        
        NSDictionary *ssidInfo = [self fetchSSIDInfo];
        NSString *ssid = ssidInfo[@"SSID"];
        
        NSString *currentPwd = [_tfNewPwd text];
        
        
        PlutoWifi *plutoWifi = [[PlutoWifi alloc] init];
        plutoWifi.ssid = ssid;
        plutoWifi.password = currentPwd;
        
        [realm beginWriteTransaction];
        [realm addOrUpdateObject: plutoWifi];
        [realm commitWriteTransaction];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [plutoManager.protocol sendRequestAT_WIFI_SETTINGS: ssid withPassword: currentPwd withChannel: arc4random() % (13 - 1) + 1];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 200 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                [self.view makeToast:@"WiFi Settings Updated Successfully, Please Reconnect Raven"];
                
                plutoManager.WiFiConnection.connected = FALSE;
                
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        });
    }
}

- (IBAction)visibilityClicked:(id)sender {
    [_tfConfirmPwd setSecureTextEntry: !_tfConfirmPwd.isSecureTextEntry];
    _tfConfirmPwd.isSecureTextEntry ? [_btnVisibility setImage:[UIImage imageNamed:@"ic_visibility_off"] forState:UIControlStateNormal] : [_btnVisibility setImage:[UIImage imageNamed:@"ic_visibility"] forState:UIControlStateNormal];
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
    NSLog(@"%s: Supported interfaces: %@", __func__, interfaceNames);
    
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
