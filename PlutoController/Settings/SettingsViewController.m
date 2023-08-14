//
//  SettingsViewController.m
//  PlutoController
//
//  Created by Drona Aviation on 08/05/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Realm/Realm.h"
#import "User.h"
#import "UserSettings.h"
#import "SettingsViewController.h"

@interface SettingsViewController()

@property (weak, nonatomic) IBOutlet UIView *swipeView;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *settingsTable;

@end

@implementation SettingsViewController

NSMutableArray *settingsImage;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    RLMResults<User *> *users = [User objectsWhere:@"userId = 'PLUTO_DEFAULT_USER'"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"userId = %@",
                         @"PLUTO_DEFAULT_USER"];
    users = [User objectsWithPredicate:pred];
    user = users[0];
    
    settingsData =[[NSMutableArray alloc]initWithObjects:@"App Settings",@"Update Firmware",@"Reset All Settings",nil];
    
    if(user.isDeveloper)
        [settingsData addObject:@"Developer Settings"];
    
    settingsImage =[[NSMutableArray alloc]initWithObjects:@"app_settings",@"Update_Firmware",@"Reset_Settings",@"dev_settings",nil];
    
    _settingsTable.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    
    __weak typeof(self) weakSelf = self;
    token = [user addNotificationBlock:^(BOOL deleted,
                                         NSArray<RLMPropertyChange *> *changes,
                                         NSError *error) {
        if (deleted) {
            NSLog(@"The object was deleted.");
        } else if (error) {
            NSLog(@"An error occurred: %@", error);
        } else {
            for (RLMPropertyChange *property in changes) {
                if ([property.name isEqualToString:@"isDeveloper"]) {
                    if(![property.value boolValue]) {
                        [self->settingsData removeLastObject];
                        [weakSelf.settingsTable reloadData];
                    } else {
                        [self->settingsData addObject:@"dev_settings"];
                        [weakSelf.settingsTable reloadData];
                    }
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

-(void)viewWillAppear:(BOOL)animated {
    [_settingsTable reloadData];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [settingsData count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.textColor = [UIColor whiteColor];
        
        cell.imageView.image = [UIImage imageNamed:settingsImage[indexPath.row]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_keyboard_arrow_left_white"]];
        imageView.transform = CGAffineTransformMakeScale(-1, 1);
        imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [imageView setTintColor:[UIColor lightGrayColor]];
        cell.accessoryView = imageView;
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
        [cell setSelectedBackgroundView:bgColorView];
    }
    
    cell.textLabel.text=settingsData[indexPath.row];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AppSettings"];
            [self addChildViewController:vc];
            [self.view addSubview:vc.view];
            [vc didMoveToParentViewController:self];
        }
            break;
            
        case 1:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FirmwareFlasher"];
            [self addChildViewController:vc];
            [self.view addSubview:vc.view];
            [vc didMoveToParentViewController:self];
        }
            break;
            
        case 2:
        {
            UIAlertController *alertDialog = [UIAlertController alertControllerWithTitle:@"Do you really want to reset all Settings?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertDialog addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                RLMResults<User *> *users = [User objectsWhere:@"userId = 'PLUTO_DEFAULT_USER'"];
                
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"userId = %@",
                                     @"PLUTO_DEFAULT_USER"];
                users = [User objectsWithPredicate:pred];
                RLMResults<UserSettings *> *userSettingsResult = [UserSettings objectsWhere:@"ANY user = %@", users[0]];
                pred = [NSPredicate predicateWithFormat:@"ANY user = %@",
                        users[0]];
                userSettingsResult = [UserSettings objectsWithPredicate:pred];
                UserSettings *userSettings = userSettingsResult[0];
                
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm beginWriteTransaction];
                userSettings.flightSensitivity = 300;
                userSettings.flightMode = 0;
                userSettings.flightControl = 0;
                userSettings.isHeadFreeMode = NO;
                userSettings.isSwipeControl = NO;
                userSettings.isVibrate = YES;
                userSettings.isSounds = YES;
                [realm commitWriteTransaction];
                
            }]];
            
            [alertDialog addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
                [alertDialog dismissViewControllerAnimated:YES completion:nil];
            }]];
            
            [self presentViewController:alertDialog animated:YES completion:nil];
        }
            break;
            
        case 3:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DevSettings"];
            [self addChildViewController:vc];
            [self.view addSubview:vc.view];
            [vc didMoveToParentViewController:self];
        }
            
            break;
    }
    
}

- (IBAction)BackToController:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)swipeRight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
