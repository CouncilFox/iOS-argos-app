//
//  MagnetoController.m
//  PlutoController
//
//  Created by Drona Aviation on 11/10/16.
//  Copyright © 2016 Drona Aviation. All rights reserved.
//

#import "MagnetoController.h"
#import "GraphsController.h"
#import "MagnetoGraphView.h"

NSTimer * mTimer;

@interface MagnetoController ()

@property (weak, nonatomic) IBOutlet MagnetoGraphView *magnetoGraph;

@end

@implementation MagnetoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    vc = [storyboard instantiateViewControllerWithIdentifier:@"a"];
    
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


-(void)viewWillAppear:(BOOL)animated {

    NSLog(@"in Viewwill Appear");
    
    mTimer=[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateGraph) userInfo:nil repeats:YES];
    
}



-(void)viewWillDisappear:(BOOL)animated {
    NSLog(@"in Viewwill Disappear");
    
    if(mTimer) {
        [mTimer invalidate];
        mTimer = nil;
    }
    
}



- (IBAction)backToController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(void)updateGraph {
    
    [plutoManager.protocol sendRequestMSP_DEBUG:graphRequests];
    NSLog(@"######## Mag=%f",magX);
    [_magnetoGraph addX:magX y:magY z:magZ];
    
}



@end
