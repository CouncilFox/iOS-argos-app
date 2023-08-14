//
//  LoginViewController.m
//  PlutoController
//
//  Created by Drona Aviation on 02/08/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "Realm/Realm.h"
#import "User.h"
#import <Photos/Photos.h>
#import "LoginViewController.h"

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UIView *developerBorderView;
@property (weak, nonatomic) IBOutlet UILabel *labelVersionName;
@property (weak, nonatomic) IBOutlet UITextField *tfUserName;
@property (weak, nonatomic) IBOutlet UIButton *btnLetsFly;
@property (strong, nonatomic) IBOutlet UIButton *developerCheckboxView;
@property (strong, nonatomic) IBOutlet UIButton *btnProfilePhoto;
@property (strong, nonatomic) IBOutlet UIImageView *ivDeveloperIcon;

@end

@implementation LoginViewController

UIImagePickerController *imagepickerController;
NSDictionary<NSString *,id> *capturedImageinfo;
NSString *userProfilePath;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _labelVersionName.text = [_labelVersionName.text stringByAppendingString: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    _btnLetsFly.layer.cornerRadius = 20;
    _btnLetsFly.clipsToBounds = YES;
    [_btnLetsFly.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnLetsFly layer] setBorderWidth:5.0f];
    _btnLetsFly.enabled = NO;
    _btnLetsFly.alpha = 0.6f;
    
    _btnProfilePhoto.layer.cornerRadius = 36;
    _btnProfilePhoto.clipsToBounds = YES;
    [_btnProfilePhoto.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [[_btnProfilePhoto layer] setBorderWidth:1.0f];
    
    _developerCheckboxView.layer.cornerRadius = 8;
    _developerCheckboxView.clipsToBounds = YES;
    [_developerCheckboxView setSelected:NO];
    
    _developerBorderView.layer.cornerRadius = 12;
    _developerBorderView.clipsToBounds = YES;
    [[_developerBorderView layer] setBorderColor:[[UIColor colorWithRed:0.07 green:0.40 blue:1.0 alpha:1.0] CGColor]];
    [[_developerBorderView layer] setBorderWidth:1.9f];
    
    CALayer *border = [CALayer layer];
    border.borderColor = [UIColor whiteColor].CGColor;
    border.frame = CGRectMake(0, _tfUserName.frame.size.height - 1.5f, _tfUserName.frame.size.width, _tfUserName.frame.size.height);
    border.borderWidth = 1.5f;
    [_tfUserName.layer addSublayer:border];
    _tfUserName.layer.masksToBounds = YES;
    NSAttributedString *placeHolderStyle = [[NSAttributedString alloc] initWithString:@"NICKNAME" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:1.0f alpha:0.28f] }];
    _tfUserName.attributedPlaceholder = placeHolderStyle;
    _tfUserName.autocorrectionType = UITextAutocorrectionTypeNo;
    _tfUserName.delegate = self;
    [_tfUserName addTarget:self action:@selector(userNameEdited:) forControlEvents:UIControlEventEditingChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [_tfUserName resignFirstResponder];
    return YES;
}

- (void)userNameEdited:(UITextField *)textField {
    
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [textField.text stringByTrimmingCharactersInSet:whitespace];
    if(trimmed.length == 0){
        self.btnLetsFly.enabled = NO;
        self.btnLetsFly.alpha = 0.6f;
    } else{
        self.btnLetsFly.enabled = YES;
        self.btnLetsFly.alpha = 1.0f;
    }
}

- (IBAction)btnLetsFlyClicked:(id)sender {
    if(nil != capturedImageinfo && nil != userProfilePath) {
        
        NSString *mediaType = [capturedImageinfo objectForKey:UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:@"public.image"]){
            UIImage *editedImage = [capturedImageinfo objectForKey:UIImagePickerControllerEditedImage];
            NSData *webData = UIImagePNGRepresentation(editedImage);
            [webData writeToFile:userProfilePath atomically:YES];
        }
    }
    
    RLMResults<User *> *users = [User objectsWhere:@"userName = 'PLUTO_DEFAULT_USER'"];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"userId = %@",
                         @"PLUTO_DEFAULT_USER"];
    users = [User objectsWithPredicate:pred];
   
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    users[0].userName = _tfUserName.text;
    users[0].isDeveloper = _developerCheckboxView.isSelected;
    users[0].userProfilePath = userProfilePath;
    [realm commitWriteTransaction];
    
    NSUserDefaults *preferencesDefault = [NSUserDefaults standardUserDefaults];
    [preferencesDefault setBool:YES forKey:@"isUserLoggedIn"];
    
    [self presentViewController:[[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"Main"] animated:YES completion:nil];
}

-(IBAction)isDeveloperViewClicked:(id)sender {
    if(_developerCheckboxView.isSelected){
        [_developerCheckboxView setSelected:NO];
        [_developerCheckboxView setBackgroundColor:[UIColor clearColor]];
        _ivDeveloperIcon.hidden = YES;
    } else {
        [_developerCheckboxView setSelected:YES];
        [_developerCheckboxView setBackgroundColor:[UIColor colorWithRed:0.82 green:0.07 blue:0.37 alpha:1.0f]];
        _ivDeveloperIcon.hidden = NO;
        
    }
}

-(IBAction)btnProfilePhotoClicked:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    if(nil != userProfilePath) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete Photo" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            userProfilePath = nil;
            [self.btnProfilePhoto setImage: [UIImage imageNamed: @"ic_default_dp"] forState:UIControlStateNormal];
        }]];
    }
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            
            switch (status){
                    
                case AVAuthorizationStatusAuthorized: {
                    [self openCameraPicker];
                }
                    break;
                    
                case AVAuthorizationStatusNotDetermined: {
                    
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                        if(granted){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self openCameraPicker];
                            });
                        }
                    }];
                }
                    break;
                    
                case AVAuthorizationStatusDenied: {
                    UIAlertController *alertDialog = [UIAlertController alertControllerWithTitle:@"Take your profile photo" message:@"Allow access to your camera to take photo for your profile" preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alertDialog addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }]];
                    
                    [alertDialog addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        
                        [alertDialog dismissViewControllerAnimated:YES completion:nil];
                    }]];
                    
                    [self presentViewController:alertDialog animated:YES completion:nil];
                    
                }
                    break;
                case AVAuthorizationStatusRestricted: {
                    
                    UIAlertController *errorDialog = [UIAlertController alertControllerWithTitle:@"Error Message" message:@"You've been restricted from using the camera on this device, please contact the device owner." preferredStyle:UIAlertControllerStyleAlert];
                    
                    [errorDialog addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
                        [errorDialog dismissViewControllerAnimated:YES completion:nil];
                    }]];
                    
                    [self presentViewController:errorDialog animated:YES completion:nil];
                    
                }
                    break;
            }
            
            
        } else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Camera Unavailable"
                                                                           message:@"Unable to find a camera on your device"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                [alert dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Choose Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        
        switch (status){
                
            case PHAuthorizationStatusAuthorized: {
                [self openPhotoLibraryPicker];
            }
                break;
                
            case PHAuthorizationStatusNotDetermined: {
                
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (status == PHAuthorizationStatusAuthorized) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self openPhotoLibraryPicker];
                        });
                    }
                }];
            }
                break;
                
            case PHAuthorizationStatusDenied: {
                UIAlertController *alertDialog = [UIAlertController alertControllerWithTitle:@"Choose your profile photo" message:@"Allow access to your photo library to choose photo for your profile" preferredStyle:UIAlertControllerStyleAlert];
                
                [alertDialog addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }]];
                
                [alertDialog addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    
                    [alertDialog dismissViewControllerAnimated:YES completion:nil];
                }]];
                
                [self presentViewController:alertDialog animated:YES completion:nil];
                
            }
                break;
            case PHAuthorizationStatusRestricted: {
                
                UIAlertController *errorDialog = [UIAlertController alertControllerWithTitle:@"Error Message" message:@"You've been restricted from using the photo library on this device, please contact the device owner." preferredStyle:UIAlertControllerStyleAlert];
                
                [errorDialog addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    [errorDialog dismissViewControllerAnimated:YES completion:nil];
                }]];
                
                [self presentViewController:errorDialog animated:YES completion:nil];
            }
                break;
        }
    }]];
    
    UIPopoverPresentationController *popPresenter = [actionSheet
                                                     popoverPresentationController];
    popPresenter.sourceView = self.view;
    popPresenter.sourceRect = CGRectMake(self.view.bounds.size.width * 0.5f, self.view.bounds.size.height * 0.5f, 0, 0);
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

-(void) openCameraPicker {
    imagepickerController = [[UIImagePickerController alloc] init];
    imagepickerController.delegate = self;
    imagepickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagepickerController.allowsEditing = YES;
    [self presentViewController:imagepickerController animated:YES completion:NULL];
    
    NSLog(@"openCameraPicker");
}

-(void) openPhotoLibraryPicker {
    imagepickerController = [[UIImagePickerController alloc] init];
    imagepickerController.delegate = self;
    imagepickerController.allowsEditing = YES;
    imagepickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagepickerController animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    capturedImageinfo = info;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    userProfilePath = [documentsDirectory stringByAppendingPathComponent:@"pilot_profile.png"];
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [_btnProfilePhoto setImage:chosenImage forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

@end
