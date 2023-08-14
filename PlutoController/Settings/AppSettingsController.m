//
//  AppSettingsController.m
//  PlutoController
//
//  Created by Drona Aviation on 17/05/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "Realm/Realm.h"
#import "User.h"
#import "UserSettings.h"
#import "AppSettingsController.h"

@interface AppSettingsController ()

@property (weak, nonatomic) IBOutlet UIView *swipeView;
@property (weak, nonatomic) IBOutlet UISwitch *switchSounds;
@property (weak, nonatomic) IBOutlet UILabel *labelAppVersion;

@end

@implementation AppSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _labelAppVersion.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    UISwipeGestureRecognizer * swipeRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
    [_swipeView addGestureRecognizer:swipeRight];
    
    realm = [RLMRealm defaultRealm];
    
    RLMResults<User *> *users = [User objectsWhere:@"userId = 'PLUTO_DEFAULT_USER'"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"userId = %@",
                         @"PLUTO_DEFAULT_USER"];
    users = [User objectsWithPredicate:pred];
    
    RLMResults<UserSettings *> *userSettings = [UserSettings objectsWhere:@"ANY user = %@", users[0]];
    pred = [NSPredicate predicateWithFormat:@"ANY user = %@",
            users[0]];
    userSettings = [UserSettings objectsWithPredicate:pred];
    currentUserSettings = userSettings[0];
    
    [_switchSounds setOn:currentUserSettings.isSounds];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)soundsSwitch:(id)sender {
    realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    currentUserSettings.isSounds = _switchSounds.isOn;
    [realm commitWriteTransaction];
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
