//
//  DevSettingsController.m
//  PlutoController
//
//  Created by Drona Aviation on 18/05/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "Util.h"
#import "DevSettingsController.h"
#import "Config.h"

@interface DevSettingsController ()

@property (weak, nonatomic) IBOutlet UIView *swipeView;
@property (weak, nonatomic) IBOutlet UILabel *labelFlightControllerID;
@property (weak, nonatomic) IBOutlet UILabel *labelAPIVersion;
@property (weak, nonatomic) IBOutlet UILabel *labelBoardID;
@property (weak, nonatomic) IBOutlet UISwitch *switchDeviceHeading;
@property (weak, nonatomic) IBOutlet UISwitch *switchDeviceGPS;
@property (weak, nonatomic) IBOutlet UISwitch *switchShowFlightData;

@end

@implementation DevSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *swipeRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
    [_swipeView addGestureRecognizer:swipeRight];
    
    [_switchDeviceHeading setOn:isDeveloperModeSensorOn];
    [_switchDeviceGPS setOn:isGPSModeOn];
    
    preferences = [NSUserDefaults standardUserDefaults];
    [_switchShowFlightData setOn:[preferences boolForKey:@"show_flight_data"]];
    
    if(plutoManager.WiFiConnection.connected) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [plutoManager.protocol sendRequest_Software_Info];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 200 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                [self.labelAPIVersion setText:[NSString stringWithFormat:@"%d.%d.0",  API_VERSION_MAJOR, API_VERSION_MINOR]];
                
                [self.labelFlightControllerID setText:[NSString stringWithFormat:@"%@\t%d.%d.%d", FLIGHT_CONTROLLER_ID, FC_versionMajor, FC_versionMinor, FC_versionPatchLevel]];
                [self.labelBoardID setText:[NSString stringWithFormat:@"%@", BOARD_ID]];
            });
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)deviceHeadingSwitch:(id)sender {
    isDeveloperModeSensorOn = [_switchDeviceHeading isOn];
}

-(IBAction)deviceGPSSwitch:(id)sender {
    isGPSModeOn = [_switchDeviceGPS isOn];
}

-(IBAction)showFlightDataSwitch:(id)sender {
    [preferences setBool:_switchShowFlightData.isOn forKey:@"show_flight_data"];
}

- (IBAction)BackToController:(id)sender {
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

-(void)swipeRight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

@end
