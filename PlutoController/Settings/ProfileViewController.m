//
//  ProfileViewController.m
//  PlutoController
//
//  Created by Drona Aviation on 08/05/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Photos/Photos.h>
#import "Realm/Realm.h"
#import "User.h"
#import "EditProfileDialogUIView.h"
#import "ProfileViewController.h"
#import "CustomProgressView.h"
#import "Util.h"

@interface ProfileViewController()

@property (weak, nonatomic) IBOutlet UIView *profileLeftCardView;
@property (weak, nonatomic) IBOutlet UIView *profileRightCardView;
@property (weak, nonatomic) IBOutlet UIView *swipeView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *btnProfileEdit;
@property (weak, nonatomic) IBOutlet UILabel *labelUserName;
@property (weak, nonatomic) IBOutlet UILabel *labelFlightTime;
@property (weak, nonatomic) IBOutlet UILabel *labelBestTime;
@property (weak, nonatomic) IBOutlet UILabel *levelName;
@property (weak, nonatomic) IBOutlet UIImageView *ivUserPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *ivDeveloperIcon;
@property (weak, nonatomic) IBOutlet UIImageView *ivMedalIcon1;
@property (weak, nonatomic) IBOutlet UIImageView *ivMedalIcon2;
@property (weak, nonatomic) IBOutlet UIImageView *ivMedalIcon3;
@property (weak, nonatomic) IBOutlet UIImageView *ivMedalIcon4;
@property (weak, nonatomic) IBOutlet UIImageView *ivMedalIcon5;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _profileLeftCardView.layer.cornerRadius = 14;
    _profileLeftCardView.clipsToBounds = YES;
    
    _profileRightCardView.layer.cornerRadius = 14;
    _profileRightCardView.clipsToBounds = YES;
    
    _btnProfileEdit.layer.cornerRadius = 22;
    _btnProfileEdit.clipsToBounds = YES;
    
    RLMResults<User *> *users = [User objectsWhere:@"userId = 'PLUTO_DEFAULT_USER'"];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"userId = %@",
                         @"PLUTO_DEFAULT_USER"];
    users = [User objectsWithPredicate:pred];
    defaultUser = users[0];
    
    RLMResults<Gaming *> *gamingResult = [Gaming objectsWhere:@"ANY user = %@", defaultUser];
    pred = [NSPredicate predicateWithFormat:@"ANY user = %@",
            users[0]];
    gamingResult = [Gaming objectsWithPredicate:pred];
    gaming = gamingResult[0];
    
    int hour = (int) gaming.totalFlightTime;
    float decimalPart = (gaming.totalFlightTime - hour) * 60;
    int minute = (int) decimalPart;
    int seconds = (int) ((decimalPart - minute) * 60);
    
    NSString *stringHour, *stringMinute, *stringSec;
    stringHour = [(hour > 9 ? @"" : @"0") stringByAppendingString:[NSString stringWithFormat:@"%i", hour]];
    stringMinute = [(minute > 9 ? @"" : @"0") stringByAppendingString:[NSString stringWithFormat:@"%i", minute]];
    stringSec = [(seconds > 9 ? @"" : @"0") stringByAppendingString:[NSString stringWithFormat:@"%i", seconds]];
    
    int bestMinute = (int) gaming.bestTime;
    int bestSec = (int) ((gaming.bestTime - bestMinute) * 60);
    
    NSString *stringBestMin, *stringBestSec;
    stringBestMin = [(bestMinute > 9 ? @"" : @"0") stringByAppendingString:[NSString stringWithFormat:@"%i", bestMinute]];
    stringBestSec = [(bestSec > 9 ? @"" : @"0") stringByAppendingString:[NSString stringWithFormat:@"%i", bestSec]];
    
    [_labelFlightTime setText: [NSString stringWithFormat: @"%@:%@:%@", stringHour, stringMinute, stringSec]];
    [_labelBestTime setText: [NSString stringWithFormat: @"%@:%@", stringBestMin, stringBestSec]];
    
    _labelUserName.text = defaultUser.userName;
    [_ivDeveloperIcon setHidden: !defaultUser.isDeveloper];
    
    _ivUserPhoto.layer.cornerRadius = 47;
    _ivUserPhoto.clipsToBounds = YES;
    [_ivUserPhoto.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [[_ivUserPhoto layer] setBorderWidth:1.8f];
    if(nil != defaultUser.userProfilePath)
        [_ivUserPhoto setImage:[[UIImage alloc] initWithContentsOfFile:defaultUser.userProfilePath]];
    [self setProgressUI];
    
    NSMutableDictionary *levelMap = [NSMutableDictionary dictionary];
    levelMap[@0] = @"Trainee";
    levelMap[@1] = @"Novice";
    levelMap[@2] = @"Rookie";
    levelMap[@3] = @"Competent";
    levelMap[@4] = @"Skilled";
    levelMap[@5] = @"Advanced";
    levelMap[@6] = @"Expert";
    levelMap[@7] = @"Master";
    levelMap[@8] = @"Captain";
    levelMap[@9] = @"Legend";
    
    [_levelName setText: [NSString stringWithFormat:@"Level %@", levelMap[@(gaming.levelNo)]]];
    
    UISwipeGestureRecognizer *swipeRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [_swipeView addGestureRecognizer:swipeRight];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    __weak typeof(self) weakSelf = self;
    
    token = [defaultUser addNotificationBlock:^(BOOL deleted,
                                                NSArray<RLMPropertyChange *> *changes,
                                                NSError *error) {
        if (deleted) {
            NSLog(@"The object was deleted.");
        } else if (error) {
            NSLog(@"An error occurred: %@", error);
        } else {
            for (RLMPropertyChange *property in changes) {
                if ([property.name isEqualToString:@"userName"])
                    weakSelf.labelUserName.text = property.value;
                
                else if([property.name isEqualToString:@"isDeveloper"])
                    [weakSelf.ivDeveloperIcon setHidden: ![property.value boolValue]];
                
                else if([property.name isEqualToString:@"userProfilePath"]) {
                    if(nil != self->defaultUser.userProfilePath)
                        [weakSelf.ivUserPhoto setImage:[[UIImage alloc] initWithContentsOfFile: self->defaultUser.userProfilePath]];
                    else
                        [weakSelf.ivUserPhoto setImage: [UIImage imageNamed: @"ic_default_dp"]];
                }
                
            }
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated{
    [token invalidate];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    
}

- (IBAction)editProfileBtnClicked:(id)sender {
    
    EditProfileDialogUIView *editProfileDialogview = [[EditProfileDialogUIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [editProfileDialogview setUser:defaultUser];
    [editProfileDialogview setViewController:self];
    [self.view addSubview:editProfileDialogview];
}

- (IBAction)BackToController:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)swipeRight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) setProgressUI {
    
    CGRect frame = _ivMedalIcon1.bounds;
    
    switch (gaming.levelNo) {
        case 1:
        case 2: {
            frame.origin.y =  _ivMedalIcon1.bounds.size.width * (1 - (gaming.points * 0.01));
            frame.origin.y = [Util map:frame.origin.y and:0 and:_ivMedalIcon1.bounds.size.width and:5 and:_ivMedalIcon1.bounds.size.width - 5];
            UIImageView *bgView = [[UIImageView alloc] initWithFrame: frame];
            [bgView setImage:[UIImage imageNamed:@"Badge_Fill"]];
            NSLog(@"origin y: %f", frame.origin.y);
            float y1 = [Util map:1 - (gaming.points * 0.01) and:0 and:1 and:0.1 and:0.9];
            bgView.layer.contentsRect = CGRectMake(0, y1, 1.0, 1.0);
            
            [self->_ivMedalIcon1 insertSubview:bgView atIndex:0];
        }
            break;
        case 3:
        case 4: {
            UIImageView *bgView = [[UIImageView alloc] initWithFrame: frame];
            [bgView setImage:[UIImage imageNamed:@"Badge_Fill"]];
            bgView.layer.contentsRect = CGRectMake(0, 0, 1.0, 1.0);
            [self->_ivMedalIcon1 insertSubview:bgView atIndex:0];
            
            CGRect frame1 = _ivMedalIcon1.bounds;
            frame1.origin.y =  _ivMedalIcon1.bounds.size.width * (1 - (gaming.points * 0.01));
            frame1.origin.y = [Util map:frame1.origin.y and:0 and:_ivMedalIcon1.bounds.size.width and:5 and:_ivMedalIcon1.bounds.size.width - 5];
            UIImageView *bgView1 = [[UIImageView alloc] initWithFrame: frame1];
            [bgView1 setImage:[UIImage imageNamed:@"Badge_Fill"]];
            float y1 = [Util map:1 - (gaming.points * 0.01) and:0 and:1 and:0.1 and:0.9];
            bgView1.layer.contentsRect = CGRectMake(0, y1, 1.0, 1.0);
            [self->_ivMedalIcon2 insertSubview:bgView1 atIndex:0];
        }
            break;
        case 5:
        case 6:
        {
            UIImageView *bgView = [[UIImageView alloc] initWithFrame: frame];
            [bgView setImage:[UIImage imageNamed:@"Badge_Fill"]];
            bgView.layer.contentsRect = CGRectMake(0, 0, 1.0, 1.0);
            [self->_ivMedalIcon1 insertSubview:bgView atIndex:0];
            
            CGRect frame1 = _ivMedalIcon1.bounds;
            UIImageView *bgView1 = [[UIImageView alloc] initWithFrame: frame1];
            [bgView1 setImage:[UIImage imageNamed:@"Badge_Fill"]];
            bgView1.layer.contentsRect = CGRectMake(0, 0, 1.0, 1.0);
            [self->_ivMedalIcon2 insertSubview:bgView1 atIndex:0];
            
            CGRect frame2 = _ivMedalIcon1.bounds;
            frame2.origin.y =  _ivMedalIcon1.bounds.size.width * (1 - (gaming.points * 0.01));
            frame2.origin.y = [Util map:frame2.origin.y and:0 and:_ivMedalIcon1.bounds.size.width and:5 and:_ivMedalIcon1.bounds.size.width - 5];
            UIImageView *bgView2 = [[UIImageView alloc] initWithFrame: frame2];
            [bgView2 setImage:[UIImage imageNamed:@"Badge_Fill"]];
            float y1 = [Util map:1 - (gaming.points * 0.01) and:0 and:1 and:0.1 and:0.9];
            bgView2.layer.contentsRect = CGRectMake(0, y1, 1.0, 1.0);
            [self->_ivMedalIcon3 insertSubview:bgView2 atIndex:0];
        }
            break;
        case 7:
        case 8:
        {
            UIImageView *bgView = [[UIImageView alloc] initWithFrame: frame];
            [bgView setImage:[UIImage imageNamed:@"Badge_Fill"]];
            bgView.layer.contentsRect = CGRectMake(0, 0, 1.0, 1.0);
            [self->_ivMedalIcon1 insertSubview:bgView atIndex:0];
            
            CGRect frame1 = _ivMedalIcon1.bounds;
            UIImageView *bgView1 = [[UIImageView alloc] initWithFrame: frame1];
            [bgView1 setImage:[UIImage imageNamed:@"Badge_Fill"]];
            bgView1.layer.contentsRect = CGRectMake(0, 0, 1.0, 1.0);
            [self->_ivMedalIcon2 insertSubview:bgView1 atIndex:0];
            
            CGRect frame2 = _ivMedalIcon1.bounds;
            UIImageView *bgView2 = [[UIImageView alloc] initWithFrame: frame2];
            [bgView2 setImage:[UIImage imageNamed:@"Badge_Fill"]];
            bgView2.layer.contentsRect = CGRectMake(0, 0, 1.0, 1.0);
            [self->_ivMedalIcon3 insertSubview:bgView2 atIndex:0];
            
            CGRect frame3 = _ivMedalIcon1.bounds;
            frame3.origin.y =  _ivMedalIcon1.bounds.size.width * (1 - (gaming.points * 0.01));
            frame3.origin.y = [Util map:frame3.origin.y and:0 and:_ivMedalIcon1.bounds.size.width and:5 and:_ivMedalIcon1.bounds.size.width - 5];
            UIImageView *bgView3 = [[UIImageView alloc] initWithFrame: frame3];
            [bgView3 setImage:[UIImage imageNamed:@"Badge_Fill"]];
            float y1 = [Util map:1 - (gaming.points * 0.01) and:0 and:1 and:0.1 and:0.9];
            bgView3.layer.contentsRect = CGRectMake(0, y1, 1.0, 1.0);
            [self->_ivMedalIcon4 insertSubview:bgView3 atIndex:0];
        }
            break;
        case 9:
        case 10:
        {
            UIImageView *bgView = [[UIImageView alloc] initWithFrame: frame];
            [bgView setImage:[UIImage imageNamed:@"Badge_Fill"]];
            bgView.layer.contentsRect = CGRectMake(0, 0, 1.0, 1.0);
            [self->_ivMedalIcon1 insertSubview:bgView atIndex:0];
            
            CGRect frame1 = _ivMedalIcon1.bounds;
            UIImageView *bgView1 = [[UIImageView alloc] initWithFrame: frame1];
            [bgView1 setImage:[UIImage imageNamed:@"Badge_Fill"]];
            bgView1.layer.contentsRect = CGRectMake(0, 0, 1.0, 1.0);
            [self->_ivMedalIcon2 insertSubview:bgView1 atIndex:0];
            
            CGRect frame2 = _ivMedalIcon1.bounds;
            UIImageView *bgView2 = [[UIImageView alloc] initWithFrame: frame2];
            [bgView2 setImage:[UIImage imageNamed:@"Badge_Fill"]];
            bgView2.layer.contentsRect = CGRectMake(0, 0, 1.0, 1.0);
            [self->_ivMedalIcon3 insertSubview:bgView2 atIndex:0];
            
            CGRect frame3 = _ivMedalIcon1.bounds;
            UIImageView *bgView3 = [[UIImageView alloc] initWithFrame: frame3];
            [bgView3 setImage:[UIImage imageNamed:@"Badge_Fill"]];
            bgView3.layer.contentsRect = CGRectMake(0, 0, 1.0, 1.0);
            [self->_ivMedalIcon4 insertSubview:bgView3 atIndex:0];
            
            CGRect frame4 = _ivMedalIcon1.bounds;
            frame4.origin.y =  _ivMedalIcon1.bounds.size.width * (1 - (gaming.points * 0.01));
            frame4.origin.y = [Util map:frame4.origin.y and:0 and:_ivMedalIcon1.bounds.size.width and:5 and:_ivMedalIcon1.bounds.size.width - 5];
            UIImageView *bgView4 = [[UIImageView alloc] initWithFrame: frame4];
            [bgView4 setImage:[UIImage imageNamed:@"Badge_Fill"]];
            float y1 = [Util map:1 - (gaming.points * 0.01) and:0 and:1 and:0.1 and:0.9];
            bgView4.layer.contentsRect = CGRectMake(0, y1, 1.0, 1.0);
            [self->_ivMedalIcon5 insertSubview:bgView4 atIndex:0];
        }
            break;
        default:
            break;
    }
}

@end
