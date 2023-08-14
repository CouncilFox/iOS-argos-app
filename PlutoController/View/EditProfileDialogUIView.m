//
//  EditProfileDialogUIView.m
//  PlutoController
//
//  Created by Drona Aviation on 30/07/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "Realm/Realm.h"
#import "User.h"
#import <Photos/Photos.h>
#import "EditProfileDialogUIView.h"

@interface EditProfileDialogUIView()

@property (strong, nonatomic) IBOutlet UIView *editPilotDialogView;
@property (strong, nonatomic) IBOutlet UIView *developerBorderView;
@property (strong, nonatomic) IBOutlet UIButton *developerCheckboxView;
@property (strong, nonatomic) IBOutlet UIButton *btnSavePilot;
@property (strong, nonatomic) IBOutlet UIButton *btnProfilePhoto;
@property (strong, nonatomic) IBOutlet UITextField *tfPilotName;
@property (strong, nonatomic) IBOutlet UIImageView *ivDeveloperIcon;

@end

@implementation EditProfileDialogUIView

User *defaultUserProfile;
UIViewController *profileViewController;
UIImagePickerController *picker;
NSDictionary<NSString *,id> *imageCapturedInfo;
NSString *profilePath;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

-(void) customInit
{
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1.0 alpha:0.1];
    visualEffectView.frame = self.bounds;
    [self addSubview:visualEffectView];
    
    [[NSBundle mainBundle] loadNibNamed:@"EditProfileDialogView" owner:self options:nil];
    
    [self addSubview:self.editPilotDialogView];
    
    self.editPilotDialogView.frame = CGRectMake(0, 0, self.frame.size.width * 0.74f, self.frame.size.height * 0.64f);
    self.editPilotDialogView.center = CGPointMake(self.frame.size.width * 0.5f, self.frame.size.height * 0.45f);
    self.editPilotDialogView.layer.cornerRadius = 7;
    self.editPilotDialogView.layer.masksToBounds = true;
    
    CALayer *border = [CALayer layer];
    border.borderColor = [UIColor whiteColor].CGColor;
    border.frame = CGRectMake(0, _tfPilotName.frame.size.height - 1.5f, _tfPilotName.frame.size.width, _tfPilotName.frame.size.height);
    border.borderWidth = 1.5f;
    [_tfPilotName.layer addSublayer:border];
    _tfPilotName.layer.masksToBounds = YES;
    _tfPilotName.autocorrectionType = UITextAutocorrectionTypeNo;
    _tfPilotName.delegate = self;
    
    _btnSavePilot.layer.cornerRadius = 20;
    _btnSavePilot.clipsToBounds = YES;
    [_btnSavePilot.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnSavePilot layer] setBorderWidth:5.0f];
    
    _btnProfilePhoto.layer.cornerRadius = 65;
    _btnProfilePhoto.clipsToBounds = YES;
    [_btnProfilePhoto.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [[_btnProfilePhoto layer] setBorderWidth:1.8f];
    
    _developerCheckboxView.layer.cornerRadius = 9;
    _developerCheckboxView.clipsToBounds = YES;
    [_developerCheckboxView setSelected:NO];
    
    _developerBorderView.layer.cornerRadius = 13;
    _developerBorderView.clipsToBounds = YES;
    [[_developerBorderView layer] setBorderColor:[[UIColor colorWithRed:0.07 green:0.40 blue:1.0 alpha:1.0] CGColor]];
    [[_developerBorderView layer] setBorderWidth:1.9f];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [_tfPilotName resignFirstResponder];
    return YES;
}

-(void) setUser: (User *) user {
    defaultUserProfile = user;
    _tfPilotName.text = defaultUserProfile.userName;
    [_ivDeveloperIcon setHidden:!defaultUserProfile.isDeveloper];
    if(defaultUserProfile.isDeveloper){
        [_developerCheckboxView setSelected: YES];
        [_developerCheckboxView setBackgroundColor:[UIColor colorWithRed:0.82 green:0.07 blue:0.37 alpha:1.0f]];
    } else {
        [_developerCheckboxView setSelected:NO];
        [_developerCheckboxView setBackgroundColor:[UIColor clearColor]];
    }
    profilePath = defaultUserProfile.userProfilePath;
    if(nil != profilePath)
        [_btnProfilePhoto setImage:[[UIImage alloc] initWithContentsOfFile:profilePath] forState: UIControlStateNormal];
    
}

-(void) setViewController: (UIViewController *) viewController {
    profileViewController = viewController;
}

-(IBAction)isDeveloperViewClicked:(id)sender {
    if(_developerCheckboxView.isSelected){
        [_developerCheckboxView setSelected:NO];
        [_developerCheckboxView setBackgroundColor:[UIColor clearColor]];
        [_ivDeveloperIcon setHidden: YES];
    } else {
        [_developerCheckboxView setSelected:YES];
        [_developerCheckboxView setBackgroundColor:[UIColor colorWithRed:0.82 green:0.07 blue:0.37 alpha:1.0f]];
        [_ivDeveloperIcon setHidden: NO];
    }
}

-(IBAction)profilePhotoBtnClicked:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    if(nil != profilePath) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete Photo" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            profilePath = nil;
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
                    
                    [profileViewController presentViewController:alertDialog animated:YES completion:nil];
                    
                }
                    break;
                case AVAuthorizationStatusRestricted: {
                    
                    UIAlertController *errorDialog = [UIAlertController alertControllerWithTitle:@"Error Message" message:@"You've been restricted from using the camera on this device, please contact the device owner." preferredStyle:UIAlertControllerStyleAlert];
                    
                    [errorDialog addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
                        [errorDialog dismissViewControllerAnimated:YES completion:nil];
                    }]];
                    
                    [profileViewController presentViewController:errorDialog animated:YES completion:nil];
                    
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
            [profileViewController presentViewController:alert animated:YES completion:nil];
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
                
                [profileViewController presentViewController:alertDialog animated:YES completion:nil];
                
            }
                break;
            case PHAuthorizationStatusRestricted: {
                
                UIAlertController *errorDialog = [UIAlertController alertControllerWithTitle:@"Error Message" message:@"You've been restricted from using the photo library on this device, please contact the device owner." preferredStyle:UIAlertControllerStyleAlert];
                
                [errorDialog addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    [errorDialog dismissViewControllerAnimated:YES completion:nil];
                }]];
                
                [profileViewController presentViewController:errorDialog animated:YES completion:nil];
                
            }
                break;
        }
    }]];
    
    
    UIPopoverPresentationController *popPresenter = [actionSheet
                                                     popoverPresentationController];
    popPresenter.sourceView = self;
    popPresenter.sourceRect = CGRectMake(self.bounds.size.width * 0.5f, self.bounds.size.height * 0.5f, 0, 0);
    [profileViewController presentViewController:actionSheet animated:YES completion:nil];
}

-(IBAction)saveBtnClicked:(id)sender {
    if(nil != imageCapturedInfo && nil != profilePath) {
        
        NSString *mediaType = [imageCapturedInfo objectForKey:UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:@"public.image"]){
            UIImage *editedImage = [imageCapturedInfo objectForKey:UIImagePickerControllerEditedImage];
            NSData *webData = UIImagePNGRepresentation(editedImage);
            [webData writeToFile:profilePath atomically:YES];
        }
    }
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    defaultUserProfile.userName = _tfPilotName.text;
    defaultUserProfile.isDeveloper = _developerCheckboxView.isSelected;
    defaultUserProfile.userProfilePath = profilePath;
    [realm commitWriteTransaction];
    [self removeFromSuperview];
}

- (IBAction)closeEditProfileDialog:(id)sender {
    [self removeFromSuperview];
}

-(void) openCameraPicker {
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.allowsEditing = YES;
    [profileViewController presentViewController:picker animated:YES completion:NULL];
}

-(void) openPhotoLibraryPicker {
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [profileViewController presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    imageCapturedInfo = info;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    profilePath = [documentsDirectory stringByAppendingPathComponent:@"pilot_profile.png"];
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [_btnProfilePhoto setImage:chosenImage forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
