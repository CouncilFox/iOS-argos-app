//
//  PIDController.m
//  PlutoController
//
//  Created by Drona Aviation on 26/06/17.
//  Copyright © 2017 Drona Aviation. All rights reserved.
//

#import "PIDController.h"
#import "MultiWi230.h"
#import "Config.h"

#define kOFFSET_FOR_KEYBOARD 72.0

@interface PIDController ()

@property (weak, nonatomic) IBOutlet UITextField *pEditText;
@property (weak, nonatomic) IBOutlet UIStepper *pStepper;

@property (weak, nonatomic) IBOutlet UITextField *iEditText;
@property (weak, nonatomic) IBOutlet UIStepper *iStepper;

@property (weak, nonatomic) IBOutlet UITextField *dEditText;
@property (weak, nonatomic) IBOutlet UIStepper *dStepper;

@property (weak, nonatomic) IBOutlet UISegmentedControl *pidType;

@end

@implementation PIDController

float P[PID_ITEMS];
float I[PID_ITEMS];
float D[PID_ITEMS];

int currentSegmentControlIndex = 0;

float confRC_RATE = 0, confRC_EXPO = 0, rollPitchRate = 0, yawRate = 0, dynamic_THR_PID = 0, throttle_MID = 0, throttle_EXPO = 0;

NSThread *PIDValuesThread;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIToolbar* pNumberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    pNumberToolbar.barStyle = UIBarStyleBlackTranslucent;
    pNumberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(pcancelNumberPad)],
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(pdoneWithNumberPad)]];
    [pNumberToolbar sizeToFit];
    
    UIToolbar* iNumberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    iNumberToolbar.barStyle = UIBarStyleBlackTranslucent;
    iNumberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(icancelNumberPad)],
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(idoneWithNumberPad)]];
    [iNumberToolbar sizeToFit];
    
    UIToolbar* dNumberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    dNumberToolbar.barStyle = UIBarStyleBlackTranslucent;
    dNumberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(dcancelNumberPad)],
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(ddoneWithNumberPad)]];
    [dNumberToolbar sizeToFit];
    
    _pEditText.inputAccessoryView = pNumberToolbar;
    _iEditText.inputAccessoryView = iNumberToolbar;
    _dEditText.inputAccessoryView = dNumberToolbar;
    
    self.pEditText.delegate = self;
    self.iEditText.delegate = self;
    self.dEditText.delegate = self;
    
    PIDValuesThread=[[NSThread alloc] initWithTarget:self selector:@selector(getPIDValues) object:nil];
    
    NSLog(@"Starting  Thread");
    [PIDValuesThread start ];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}


-(void)viewDidDisappear:(BOOL)animated{
    for(int i = 0; i < 4; i++){
        byteP[i] = 0;
        byteI[i] = 0;
        byteD[i] = 0;
    }
    currentSegmentControlIndex = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)backToSettings:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)pStepperValueChanged:(UIStepper *)sender {
    
    [_pEditText setText:[NSString stringWithFormat:@"%.1f", sender.value]];
    
}

- (IBAction)iStepperValueChanged:(UIStepper *)sender {
    
    [_iEditText setText:[NSString stringWithFormat:@"%.3f", sender.value]];
}

- (IBAction)dStepperValueChanged:(UIStepper *)sender {
    
    [_dEditText setText:[NSString stringWithFormat:@"%.0f", sender.value]];
}


-(BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    if (theTextField == self.dEditText) {
        [theTextField resignFirstResponder];
    } else if (theTextField == self.iEditText) {
        [self.dEditText becomeFirstResponder];
    } else if(theTextField == self.pEditText) {
        [self.iEditText becomeFirstResponder];
    }
    return YES;
    
}

-(void)pcancelNumberPad{
    [_pEditText resignFirstResponder];
    [_pEditText setText: [NSString stringWithFormat:@"%.1f",P[currentSegmentControlIndex]]];
    [_pStepper setValue:P[currentSegmentControlIndex]];
}

-(void)pdoneWithNumberPad{
    [_pEditText resignFirstResponder];
}

-(void)icancelNumberPad{
    [_iEditText resignFirstResponder];
    [_iEditText setText: [NSString stringWithFormat:@"%.3f",I[currentSegmentControlIndex]]];
    [_iStepper setValue:I[currentSegmentControlIndex]];
}

-(void)idoneWithNumberPad{
    [_iEditText resignFirstResponder];
}

-(void)dcancelNumberPad{
    [_dEditText resignFirstResponder];
    [_dEditText setText: [NSString stringWithFormat:@"%.0f",D[currentSegmentControlIndex]]];
    [_dStepper setValue:D[currentSegmentControlIndex]];
}

-(void)ddoneWithNumberPad{
    [_dEditText resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 5;
}

-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0) {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0) {
        // [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0) {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0) {
        [self setViewMovedUp:NO];
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

- (IBAction)pInputDone:(UITextField *)sender {
    
    NSString *pValueString=[sender text];
    
    float pValue=[pValueString floatValue];
    
    
    if (pValue > 20) {
        pValue = 20;
    }
    
    else if (pValue < 0) {
        pValue = 0;
    }
    
    [_pStepper setValue:pValue];
    
    [_pEditText setText:[NSString stringWithFormat:@"%.1f",pValue]];
}


- (IBAction)iInputDone:(UITextField *)sender {
    
    NSString *iValueString=[sender text];
    
    float iValue=[iValueString floatValue];
    
    if (iValue > 0.250) {
        iValue = 0.250;
    }
    
    else if (iValue < 0) {
        iValue= 0;
    }
    
    [_iStepper setValue:iValue];
    
    [_iEditText setText:[NSString stringWithFormat:@"%.3f",iValue]];
    
}

- (IBAction)dInputDone:(UITextField *)sender {
    
    NSString *dValueString =[sender text];
    
    float dValue = [dValueString floatValue];
    
    if (dValue > 100) {
        dValue = 100;
    }
    
    else if (dValue < 0) {
        dValue = 0;
    }
    
    [_dStepper setValue:dValue];
    
    [_dEditText setText:[NSString stringWithFormat:@"%.0f",dValue]];
    
}

-(IBAction)indexChanged:(id)sender {
    
    P[currentSegmentControlIndex] = [_pEditText.text floatValue];
    I[currentSegmentControlIndex] = [_iEditText.text floatValue];
    D[currentSegmentControlIndex] = [_dEditText.text floatValue];
    currentSegmentControlIndex = self.pidType.selectedSegmentIndex;
    NSLog(@"control %d", currentSegmentControlIndex);
    
    [_pEditText setText: [NSString stringWithFormat:@"%.1f",P[currentSegmentControlIndex]]];
    [_iEditText setText: [NSString stringWithFormat:@"%.3f",I[currentSegmentControlIndex]]];
    [_dEditText setText: [NSString stringWithFormat:@"%.0f",D[currentSegmentControlIndex]]];
    
    [_pStepper setValue:P[currentSegmentControlIndex]];
    [_iStepper setValue:I[currentSegmentControlIndex]];
    [_dStepper setValue:D[currentSegmentControlIndex]];
}

- (IBAction)setPIDValues:(id)sender {
    
    if(plutoManager.WiFiConnection.connected) {
        
        [plutoManager.protocol sendRequestMSP_RC_TUNING];
        
        usleep(200000);
        
        confRC_RATE = [[[NSString localizedStringWithFormat:@"%.2F", (float) byteRC_RATE / 100.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        confRC_EXPO = [[[NSString localizedStringWithFormat:@"%.2F", (float) byteRC_EXPO / 100.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        rollPitchRate = [[[NSString localizedStringWithFormat:@"%.2F", (float) byteRollPitchRate / 100.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        yawRate = [[[NSString localizedStringWithFormat:@"%.2F", (float) byteYawRate / 100.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        dynamic_THR_PID = [[[NSString localizedStringWithFormat:@"%.2F", (float) byteDynThrPID / 100.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        throttle_MID = [[[NSString localizedStringWithFormat:@"%.2F", (float) byteThrottle_MID / 100.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        throttle_EXPO = [[[NSString localizedStringWithFormat:@"%.2F", (float) byteThrottle_EXPO / 100.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        
        P[currentSegmentControlIndex] = [_pEditText.text floatValue];
        I[currentSegmentControlIndex] = [_iEditText.text floatValue];
        D[currentSegmentControlIndex] = [_dEditText.text floatValue];
        
        P[4] = [[[NSString localizedStringWithFormat:@"%.2F", (float) byteP[4] / 100.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        P[5] = [[[NSString localizedStringWithFormat:@"%.1F", (float) byteP[5] / 10.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        P[6] = [[[NSString localizedStringWithFormat:@"%.1F", (float) byteP[6] / 10.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        P[7] = [[[NSString localizedStringWithFormat:@"%.1F", (float) byteP[7] / 10.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        P[8] = [[[NSString localizedStringWithFormat:@"%.1F", (float) byteP[8] / 10.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        P[9] = [[[NSString localizedStringWithFormat:@"%.1F", (float) byteP[9] / 10.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        
        I[4] = [[[NSString localizedStringWithFormat:@"%.1F", (float) byteI[4] / 100.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        I[5] = [[[NSString localizedStringWithFormat:@"%.2F", (float) byteI[5] / 100.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        I[6] = [[[NSString localizedStringWithFormat:@"%.2F", (float) byteI[6] / 100.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        I[7] = [[[NSString localizedStringWithFormat:@"%.3F", (float) byteI[7] / 1000.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        I[8] = [[[NSString localizedStringWithFormat:@"%.3F", (float) byteI[8] / 1000.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        I[9] = [[[NSString localizedStringWithFormat:@"%.3F", (float) byteI[9] / 1000.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        
        D[4] = [[[NSString localizedStringWithFormat:@"%.0F", (float) byteD[4]] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        D[5] = [[[NSString localizedStringWithFormat:@"%.3F", (float) byteD[5] / 1000.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        D[6] = [[[NSString localizedStringWithFormat:@"%.3F", (float) byteD[6] / 1000.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        D[7] = [[[NSString localizedStringWithFormat:@"%.0F", (float) byteD[7]] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        D[8] = [[[NSString localizedStringWithFormat:@"%.3F", (float) byteD[8]] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        D[9] = [[[NSString localizedStringWithFormat:@"%.3F", (float) byteD[9]] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        
        [plutoManager.protocol sendRequestMSP_SET_PID:confRC_RATE and:confRC_EXPO and:rollPitchRate and:yawRate and:dynamic_THR_PID and:throttle_MID and:throttle_EXPO and:P and:I and:D];
        [plutoManager.protocol sendRequestMSP_EEPROM_WRITE];
        
        [self.view makeToast:@"PID values updated"];
        
    }
    
    else {
        [self.view makeToast:@"Raven is not connected"];
    }
    
}


-(void) getPIDValues {
    
    [plutoManager.protocol sendRequestMSP_PID];

    usleep(300000);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
         P[0] = [[[NSString localizedStringWithFormat:@"%.1F", (float) byteP[0] / 10.0]stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
         P[1] = [[[NSString localizedStringWithFormat:@"%.1F", (float) byteP[1] / 10.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
         P[2] = [[[NSString localizedStringWithFormat:@"%.1F", (float) byteP[2] / 10.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        P[3] = [[[NSString localizedStringWithFormat:@"%.1F", (float) byteP[3] / 10.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        
        NSLog(@"P[0]: %f %d", P[0], byteP[0]);
        
        I[0] = [[[NSString localizedStringWithFormat:@"%.3F", (float) byteI[0] / 1000.0]stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        I[1] = [[[NSString localizedStringWithFormat:@"%.3F", (float) byteI[1] / 1000.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        I[2] = [[[NSString localizedStringWithFormat:@"%.3F", (float) byteI[2] / 1000.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        I[3] = [[[NSString localizedStringWithFormat:@"%.3F", (float) byteI[3] / 1000.0] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        
        D[0] = [[[NSString localizedStringWithFormat:@"%.0F", (float) byteD[0]]stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        D[1] = [[[NSString localizedStringWithFormat:@"%.0F", (float) byteD[1]] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        D[2] = [[[NSString localizedStringWithFormat:@"%.0F", (float) byteD[2]] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        D[3] = [[[NSString localizedStringWithFormat:@"%.0F", (float) byteD[3]] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
        
        [_pEditText setText: [NSString stringWithFormat:@"%.1f",P[currentSegmentControlIndex]]];
        [_iEditText setText: [NSString stringWithFormat:@"%.3f",I[currentSegmentControlIndex]]];
        [_dEditText setText: [NSString stringWithFormat:@"%.0f",D[currentSegmentControlIndex]]];
    });
    
}

@end
