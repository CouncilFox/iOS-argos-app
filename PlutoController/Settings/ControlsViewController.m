//
//  ControlsViewController.m
//  PlutoController
//
//  Created by Drona Aviation on 08/05/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ControlsViewController.h"
#import "MultiWi230.h"
#import "Util.h"
#import "Realm/Realm.h"
#import "User.h"
#import "CustomSlider.h"

@interface ControlsViewController()

@property (weak, nonatomic) IBOutlet UIView *swipeView;
@property (weak, nonatomic) IBOutlet UIView *leftJoystickView;
@property (weak, nonatomic) IBOutlet UIView *rightJoystickView;
@property (weak, nonatomic) IBOutlet UIImageView *ivTiltMode;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *btnSwipeControls;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scAltholdThrottle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scJoystickTilt;
@property (weak, nonatomic) IBOutlet UISlider *sliderMaxAlt;
@property (weak, nonatomic) IBOutlet UISlider *sliderSensitivity;
@property (weak, nonatomic) IBOutlet UILabel *labelMaxAltSupported;
@property (weak, nonatomic) IBOutlet UILabel *labelAltitudeValue;
@property (weak, nonatomic) IBOutlet UILabel *labelHeadfree;
@property (weak, nonatomic) IBOutlet UISwitch *swHeadFreeMode;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightRootView;

@end

@implementation ControlsViewController

CAShapeLayer *maskLayerWhiteRight;
CAShapeLayer *borderLayerWhiteRight;

CAShapeLayer *maskLayerWhiteLeft;
CAShapeLayer *borderLayerWhiteLeft;

CAShapeLayer *maskLayerWhiteRight1;
CAShapeLayer *borderLayerWhiteRight1;

CAShapeLayer *maskLayerWhiteLeft1;
CAShapeLayer *borderLayerWhiteLeft1;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [self initMembers];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [UIFont boldSystemFontOfSize:13.0f],
                                 NSForegroundColorAttributeName : [UIColor whiteColor]
                                 };
    
    leftSkView = (SKView *)_leftJoystickView;
    leftSkView.allowsTransparency = YES;
    leftScene = [LeftJoystickScene sceneWithSize:leftSkView.bounds.size];
    leftScene.scaleMode = SKSceneScaleModeAspectFill;
    [leftScene setInnerControlForAltHoldThrottle];
    [leftSkView presentScene:leftScene];
    
    rightSkView = (SKView *)_rightJoystickView;
    rightSkView.allowsTransparency = YES;
    rightScene = [RightJoystickScene sceneWithSize:leftSkView.bounds.size]; 
    rightScene.scaleMode = SKSceneScaleModeAspectFill;
    [rightSkView presentScene:rightScene];
    
    [_scAltholdThrottle setTitleTextAttributes:attributes
                                      forState:UIControlStateSelected];
    [_scAltholdThrottle setTitleTextAttributes:attributes
                                      forState:UIControlStateNormal];
    
    [_scJoystickTilt setTitleTextAttributes:attributes
                                   forState:UIControlStateSelected];
    [_scJoystickTilt setTitleTextAttributes:attributes
                                   forState:UIControlStateNormal];
    
    _scAltholdThrottle.subviews[1].layer.mask = maskLayerWhiteRight;
    [[_scAltholdThrottle.subviews[1] layer] addSublayer:borderLayerWhiteRight];
    _scAltholdThrottle.subviews[0].layer.mask = maskLayerWhiteLeft;
    [[_scAltholdThrottle.subviews[0] layer] addSublayer:borderLayerWhiteLeft];
    
    _scJoystickTilt.subviews[0].layer.mask = maskLayerWhiteLeft1;
    [[_scJoystickTilt.subviews[0] layer] addSublayer:borderLayerWhiteLeft1];
    _scJoystickTilt.subviews[1].layer.mask = maskLayerWhiteRight1;
    [[_scJoystickTilt.subviews[1] layer] addSublayer:borderLayerWhiteRight1];
    
    _btnSwipeControls.layer.cornerRadius = 20;
    _btnSwipeControls.clipsToBounds = YES;
    [_btnSwipeControls.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnSwipeControls layer] setBorderWidth:5.0f];
    
    RLMResults<User *> *users = [User objectsWhere:@"userId = 'PLUTO_DEFAULT_USER'"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"userId = %@",
                         @"PLUTO_DEFAULT_USER"];
    users = [User objectsWithPredicate:pred];
    
    RLMResults<UserSettings *> *userSettings = [UserSettings objectsWhere:@"ANY user = %@", users[0]];
    pred = [NSPredicate predicateWithFormat:@"ANY user = %@",
            users[0]];
    userSettings = [UserSettings objectsWithPredicate:pred];
    defaultUserSettings = userSettings[0];
    
    [(CustomSlider *)_sliderMaxAlt setGradient];
    [(CustomSlider *)_sliderSensitivity setGradient];
    [_sliderSensitivity setValue:defaultUserSettings.flightSensitivity];
    
    [_scJoystickTilt setSelectedSegmentIndex:defaultUserSettings.flightControl];
    [_ivTiltMode setHidden:!defaultUserSettings.flightControl];
    
    [_scAltholdThrottle setSelectedSegmentIndex:defaultUserSettings.flightMode];
    [_swHeadFreeMode setOn:defaultUserSettings.isHeadFreeMode];
    
    if(plutoManager.WiFiConnection.connected) {
        
        if([Util isCurrentFirmwareMagis]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [plutoManager.protocol sendRequestMSP_GET_MAX_ALT];
                usleep(100000);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.sliderMaxAlt setValue:maxAlt > 0 ? (maxAlt / 100) - 2 : self.sliderMaxAlt.maximumValue];
                    
                    NSLog(@"max alt: %d", maxAlt);
                
                    [self.labelAltitudeValue setText:[NSString stringWithFormat:@"%d%@", (int)self.sliderMaxAlt.value + 2, @"m"]];
                    
                    int val = ((int)self.sliderMaxAlt.value * (self.sliderMaxAlt.frame.size.width)) / self.sliderMaxAlt.maximumValue;
                    CGRect rect = self.labelAltitudeValue.frame;
                    rect.origin.x = self.sliderMaxAlt.frame.origin.x + val - (self.sliderMaxAlt.value * 0.73f);
                    self.labelAltitudeValue.frame = rect;
                });
                
            });
        }
        _labelMaxAltSupported.hidden = [Util isCurrentFirmwareMagis] ? YES : NO;
    }
    
    __weak typeof(self) weakSelf = self;
    token = [defaultUserSettings addNotificationBlock:^(BOOL deleted,
                                                        NSArray<RLMPropertyChange *> *changes,
                                                        NSError *error) {
        if (deleted) {
            NSLog(@"The object was deleted.");
        } else if (error) {
            NSLog(@"An error occurred: %@", error);
        } else {
            for (RLMPropertyChange *property in changes) {
                if ([property.name isEqualToString:@"flightSensitivity"])
                    [weakSelf.sliderSensitivity setValue:[property.value intValue]];
                
                else if([property.name isEqualToString:@"flightControl"]) {
                    [weakSelf.scJoystickTilt setSelectedSegmentIndex:[property.value intValue]];
                    [weakSelf.ivTiltMode setHidden:![property.value intValue]];
                }
                
                else if ([property.name isEqualToString:@"flightMode"]) {
                    [weakSelf.scAltholdThrottle setSelectedSegmentIndex:[property.value intValue]];
                    altholdOrThrottle = [property.value intValue];
                    [self->leftScene setInnerControlForAltHoldThrottle];
                }
                
                else if ([property.name isEqualToString:@"isHeadFreeMode"]) {
                    [weakSelf.swHeadFreeMode setOn:[property.value boolValue]];
                    isHeadFreeMode = [property.value boolValue];
                }
            }
        }
    }];
    
    UISwipeGestureRecognizer * swipeRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
    [_swipeView addGestureRecognizer:swipeRight];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    if([Util droneType:[NSUserDefaults standardUserDefaults]] == 0) {
        _swHeadFreeMode.hidden = YES;
        _labelHeadfree.hidden = YES;
        _heightRootView.constant = 466;
    }
}

-(void)viewWillAppear:(BOOL)animated {

}

- (void)dealloc {
    [token invalidate];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    
}

- (IBAction)BackToController:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)altholdThrottleValueChange:(id)sender {
    
    switch (_scAltholdThrottle.selectedSegmentIndex) {
        case 0:
            [realm beginWriteTransaction];
            defaultUserSettings.flightMode = 0;
            altholdOrThrottle = 0;
            [realm commitWriteTransaction];
            break;
            
        case 1:
            [realm beginWriteTransaction];
            defaultUserSettings.flightMode = 1;
            altholdOrThrottle = 1;
            [realm commitWriteTransaction];
            break;
            
        default:
            break;
    }
    
    [leftScene setInnerControlForAltHoldThrottle];
}

- (IBAction)headFreeValueChanged:(id)sender {
    
    [realm beginWriteTransaction];
    defaultUserSettings.isHeadFreeMode = [_swHeadFreeMode isOn];
    isHeadFreeMode = [_swHeadFreeMode isOn];
    [realm commitWriteTransaction];
}

- (IBAction)joystickTiltValueChange:(id)sender {
    
    switch (_scJoystickTilt.selectedSegmentIndex) {
        case 0:
            [realm beginWriteTransaction];
            defaultUserSettings.flightControl = 0;
            [realm commitWriteTransaction];
            [_ivTiltMode setHidden:YES];
            break;
            
        case 1:
            [realm beginWriteTransaction];
            defaultUserSettings.flightControl = 1;
            [realm commitWriteTransaction];
            [_ivTiltMode setHidden:NO];
            break;
        
        default:
            break;
    }
}

-(void) initMembers {
    realm = [RLMRealm defaultRealm];
    
    CGRect outline = CGRectMake(_scAltholdThrottle.bounds.origin.x, _scAltholdThrottle.bounds.origin.y, _scAltholdThrottle.bounds.size.width * 0.5f, _scAltholdThrottle.bounds.size.height);
    
    maskLayerWhiteRight = [CAShapeLayer layer];
    maskLayerWhiteRight.path = [UIBezierPath bezierPathWithRoundedRect: outline byRoundingCorners: UIRectCornerTopRight | UIRectCornerBottomRight  cornerRadii: CGSizeMake(20, 20)].CGPath;
    
    
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect: outline byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(20, 20)];
    borderLayerWhiteRight = [CAShapeLayer layer];
    borderLayerWhiteRight.frame       = _scAltholdThrottle.subviews[0].bounds;
    borderLayerWhiteRight.path        = borderPath.CGPath;
    borderLayerWhiteRight.strokeColor = [UIColor whiteColor].CGColor;
    borderLayerWhiteRight.fillColor   = [UIColor clearColor].CGColor;
    borderLayerWhiteRight.lineWidth   = 2.0f;
    
    maskLayerWhiteLeft = [CAShapeLayer layer];
    maskLayerWhiteLeft.path = [UIBezierPath bezierPathWithRoundedRect: outline byRoundingCorners: UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii: CGSizeMake(20, 20)].CGPath;
    UIBezierPath *borderPath1 = [UIBezierPath bezierPathWithRoundedRect: outline byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(20, 20)];
    borderLayerWhiteLeft = [CAShapeLayer layer];
    borderLayerWhiteLeft.frame       = _scAltholdThrottle.subviews[0].bounds;
    borderLayerWhiteLeft.path        = borderPath1.CGPath;
    borderLayerWhiteLeft.strokeColor = [UIColor whiteColor].CGColor;
    borderLayerWhiteLeft.fillColor   = [UIColor clearColor].CGColor;
    borderLayerWhiteLeft.lineWidth   = 2.0f;
    
    maskLayerWhiteRight1 = [CAShapeLayer layer];
    maskLayerWhiteRight1.path = [UIBezierPath bezierPathWithRoundedRect: outline byRoundingCorners: UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii: (CGSize){20.0, 20.0}].CGPath;
    borderLayerWhiteRight1 = [CAShapeLayer layer];
    borderLayerWhiteRight1.frame       = _scAltholdThrottle.subviews[0].bounds;
    borderLayerWhiteRight1.path        = borderPath.CGPath;
    borderLayerWhiteRight1.strokeColor = [UIColor whiteColor].CGColor;
    borderLayerWhiteRight1.fillColor   = [UIColor clearColor].CGColor;
    borderLayerWhiteRight1.lineWidth   = 2.0f;
    
    maskLayerWhiteLeft1 = [CAShapeLayer layer];
    maskLayerWhiteLeft1.path = [UIBezierPath bezierPathWithRoundedRect: outline byRoundingCorners: UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii: CGSizeMake(20, 20)].CGPath;
    borderLayerWhiteLeft1 = [CAShapeLayer layer];
    borderLayerWhiteLeft1.frame       = _scAltholdThrottle.subviews[0].bounds;
    borderLayerWhiteLeft1.path        = borderPath1.CGPath;
    borderLayerWhiteLeft1.strokeColor = [UIColor whiteColor].CGColor;
    borderLayerWhiteLeft1.fillColor   = [UIColor clearColor].CGColor;
    borderLayerWhiteLeft1.lineWidth   = 2.0f;
}

-(IBAction)sensitivitySliderValueChanged:(id)sender {
    [realm beginWriteTransaction];
    defaultUserSettings.flightSensitivity = _sliderSensitivity.value;
    [realm commitWriteTransaction];
}

-(IBAction)altitudeSliderValueChanged:(id)sender {
    int val = ((int)_sliderMaxAlt.value * (_sliderMaxAlt.frame.size.width)) / _sliderMaxAlt.maximumValue;
    CGRect rect = _labelAltitudeValue.frame;
    rect.origin.x = _sliderMaxAlt.frame.origin.x + val - (_sliderMaxAlt.value * 0.73f);
    _labelAltitudeValue.frame = rect;
    _labelAltitudeValue.text = [NSString stringWithFormat:@"%d%@", (int)_sliderMaxAlt.value + 2, @"m"];
    
    maxAlt = (_sliderMaxAlt.value + 2) * 100;
    isAltitudeSet = true;
}

-(void)swipeRight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
