//
//  AuxDialogOptionUIView.m
//  PlutoController
//
//  Created by Drona Aviation on 21/07/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "AuxDialogOptionUIView.h"
#import "ViewController.h"

@interface AuxDialogOptionUIView()

@property (strong, nonatomic) IBOutlet UIView *auxDialogView;

@property (strong, nonatomic) IBOutlet UIButton *btnClose;
@property (strong, nonatomic) IBOutlet UIButton *btnFlipMode;
@property (strong, nonatomic) IBOutlet UIButton *btnDevMode;

@property (strong, nonatomic) IBOutlet UILabel *labelDevMode;
@property (strong, nonatomic) IBOutlet UILabel *labelFlipMode;

@end

@implementation AuxDialogOptionUIView

ViewController *mainViewController;

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
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1.0 alpha:0.1];
    visualEffectView.frame = self.bounds;
    visualEffectView.alpha = 0.81f;
    [self addSubview:visualEffectView];
    
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeAuxDialog:)];
    [self addGestureRecognizer:singleTap];
    
    [[NSBundle mainBundle] loadNibNamed:@"AuxOptionDialog" owner:self options:nil];
    
    [self addSubview:self.auxDialogView];
    
    UITapGestureRecognizer *fakeTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tempFakeClick:)];
    [self.auxDialogView addGestureRecognizer:fakeTap];
    
    self.auxDialogView.frame = CGRectMake(0, 0, self.frame.size.width * 0.60f, self.frame.size.height * 0.60f);
    self.auxDialogView.center = CGPointMake(self.frame.size.width * 0.5f, self.frame.size.height * 0.5f);
    self.auxDialogView.layer.cornerRadius = 7;
    self.auxDialogView.layer.masksToBounds = true;
    
    _btnFlipMode.layer.cornerRadius = 8;
    _btnFlipMode.layer.masksToBounds = true;
    [_btnFlipMode.layer setBorderColor:[[UIColor colorWithRed:0.82 green:0.07 blue:0.37 alpha:1.0f] CGColor]];
    [_btnDevMode.layer setBorderColor:[[UIColor colorWithRed:0.82 green:0.07 blue:0.37 alpha:1.0f] CGColor]];
    
    [_btnFlipMode setImage:[UIImage imageNamed:@"ic_drone_flip_aux_disable"] forState:UIControlStateNormal];
    [_btnFlipMode setImage:[UIImage imageNamed:@"ic_drone_flip_aux"] forState:UIControlStateSelected];
    
    [_btnDevMode setImage:[UIImage imageNamed:@"ic_developer_mode_aux_disable"] forState:UIControlStateNormal];
    [_btnDevMode setImage:[UIImage imageNamed:@"ic_developer_mode_aux"] forState:UIControlStateSelected];
    
    _btnDevMode.layer.cornerRadius = 8;
    _btnDevMode.layer.masksToBounds = true;
    
    _btnClose.layer.cornerRadius = 4;
    _btnClose.layer.masksToBounds = true;
}

- (IBAction)btnDevModeClicked:(id)sender {
    _btnDevMode.alpha = 1.0f;
    _btnFlipMode.alpha = 0.8f;
    [[_btnFlipMode layer] setBorderWidth:0.0f];
    [[_btnDevMode layer] setBorderWidth:3.0f];
    _btnDevMode.selected = YES;
    _btnFlipMode.selected = NO;
    
    _labelDevMode.textColor = [UIColor colorWithRed:0.82 green:0.07 blue:0.37 alpha:1.0f];
    _labelFlipMode.textColor = [UIColor whiteColor];
    
    [mainViewController setAuxButtonStatus: YES];
}

- (IBAction)btnFlipModeClicked:(id)sender {
    _btnDevMode.alpha = 0.8f;
    _btnFlipMode.alpha = 1.0f;
    [[_btnDevMode layer] setBorderWidth:0.0f];
    [[_btnFlipMode layer] setBorderWidth:3.0f];
    _btnFlipMode.selected = YES;
    _btnDevMode.selected = NO;
    
    _labelFlipMode.textColor = [UIColor colorWithRed:0.82 green:0.07 blue:0.37 alpha:1.0f];
    _labelDevMode.textColor = [UIColor whiteColor];
    
    [mainViewController setAuxButtonStatus: NO];
}

- (void) setViewControllerAndAuxType: (ViewController *) viewController and: (BOOL) isDevModeSelected{
    mainViewController = viewController;
    if(isDevModeSelected){
        _btnDevMode.alpha = 1.0f;
        _btnFlipMode.alpha = 0.8f;
        [[_btnFlipMode layer] setBorderWidth:0.0f];
        [[_btnDevMode layer] setBorderWidth:3.0f];
        _btnDevMode.selected = YES;
        _btnFlipMode.selected = NO;
        
        _labelDevMode.textColor = [UIColor colorWithRed:0.82 green:0.07 blue:0.37 alpha:1.0f];
        _labelFlipMode.textColor = [UIColor whiteColor];
    } else {
        _btnDevMode.alpha = 0.8f;
        _btnFlipMode.alpha = 1.0f;
        [[_btnDevMode layer] setBorderWidth:0.0f];
        [[_btnFlipMode layer] setBorderWidth:3.0f];
        _btnFlipMode.selected = YES;
        _btnDevMode.selected = NO;
        
        _labelFlipMode.textColor = [UIColor colorWithRed:0.82 green:0.07 blue:0.37 alpha:1.0f];
        _labelDevMode.textColor = [UIColor whiteColor];
    }
    
}

- (IBAction)closeAuxDialog:(id)sender {
    _isAuxDialogViewOpen = false;
    [self removeFromSuperview];
}

- (IBAction)tempFakeClick:(id)sender {
    
}

@end
