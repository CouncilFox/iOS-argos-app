//
//  RecoverPwdDialogView.m
//  PlutoController
//
//  Created by Drona Aviation on 29/11/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "RecoverPwdDialogView.h"
#import "Realm/Realm.h"

@interface RecoverPwdDialogView()

@property (strong, nonatomic) IBOutlet UIView *recoverPwdDialogView;
@property (strong, nonatomic) IBOutlet UITextField *tfWifiName;
@property (strong, nonatomic) IBOutlet UILabel *labelWifiError;
@property (strong, nonatomic) IBOutlet UILabel *labelWifiName;
@property (strong, nonatomic) IBOutlet UILabel *labelPwdInfo;
@property (strong, nonatomic) IBOutlet UIButton *btnDone;
@property (strong, nonatomic) IBOutlet UIButton *btnOk;

@end

@implementation RecoverPwdDialogView

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
    
    [[NSBundle mainBundle] loadNibNamed:@"RecoverPwdDialog" owner:self options:nil];
    
    [self addSubview:self.recoverPwdDialogView];
    
    self.recoverPwdDialogView.frame = CGRectMake(0, 0, self.frame.size.width * 0.73f, self.frame.size.height * 0.50f);
    self.recoverPwdDialogView.center = CGPointMake(self.frame.size.width * 0.5f, self.frame.size.height * 0.45f);
    
    self.recoverPwdDialogView.layer.cornerRadius = 7;
    self.recoverPwdDialogView.layer.masksToBounds = true;
    
    _btnDone.layer.cornerRadius = 20;
    _btnDone.clipsToBounds = YES;
    [_btnDone.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnDone layer] setBorderWidth:5.0f];
    [_btnDone setTitleColor:[UIColor colorWithRed:18.0f/255.0f green:186.0f/255.0f blue:144.0f/255.0f alpha:1.0f] forState:UIControlStateSelected];
    _btnDone.userInteractionEnabled = NO;
    
    _btnOk.layer.cornerRadius = 20;
    _btnOk.clipsToBounds = YES;
    [_btnOk.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnOk layer] setBorderWidth:5.0f];
    [_btnOk setTitleColor:[UIColor colorWithRed:18.0f/255.0f green:186.0f/255.0f blue:144.0f/255.0f alpha:1.0f] forState:UIControlStateSelected];
    
    _tfWifiName.layer.masksToBounds = YES;
    _tfWifiName.layer.borderColor = [[UIColor whiteColor]CGColor];
    _tfWifiName.layer.borderWidth = 1.0f;
    _tfWifiName.autocorrectionType = UITextAutocorrectionTypeNo;
    _tfWifiName.delegate = self;
}

- (IBAction)closeRecoverPwdDialog:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)okPwdClicked:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)donePwdClicked:(id)sender {
    RLMResults<PlutoWifi *> *plutoWifiResult = [PlutoWifi objectsWhere:@"ssid = %@", _tfWifiName.text];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"ssid = %@", _tfWifiName.text];
    plutoWifiResult = [PlutoWifi objectsWithPredicate:pred];
    
    if(plutoWifiResult.count > 0) {
        NSLog(@"pwd: %@", plutoWifiResult[0]);
        
        [_labelPwdInfo setText: [NSString stringWithFormat:@"Password for %@ is %@", _tfWifiName.text, plutoWifiResult[0].password]];
    } else {
         [_labelPwdInfo setText: [NSString stringWithFormat:@"Password for %@ is not found", _tfWifiName.text]];
    }
    
    _labelWifiName.hidden = YES;
    _btnDone.hidden = YES;
    _tfWifiName.hidden = YES;
    _btnOk.hidden = NO;
    _labelPwdInfo.hidden = NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.layer.borderColor = [[UIColor whiteColor]CGColor];
    [_labelWifiError setHidden:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    _btnDone.alpha = 1.0f;
    _btnDone.userInteractionEnabled = YES;
    
    if(textField.text.length == 0) {
        textField.layer.borderColor = [[UIColor redColor]CGColor];
        [_labelWifiError setHidden:NO];
        _btnDone.alpha = 0.5f;
        _btnDone.userInteractionEnabled = NO;
    }
    
    [_tfWifiName resignFirstResponder];

    return YES;
}

@end
