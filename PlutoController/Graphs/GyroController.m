//
//  GyroController.m
//  PlutoController
//
//  Created by Drona Aviation on 11/10/16.
//  Copyright © 2016 Drona Aviation. All rights reserved.
//

#import "GyroController.h"
#import "GraphsController.h"
#import "GyroGraphView.h"


NSTimer * gTimer;

@interface GyroController ()
@property (weak, nonatomic) IBOutlet GyroGraphView *gyroGraph;

@end

@implementation GyroController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    
    gTimer=[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateGraph) userInfo:nil repeats:YES];
    
}



-(void)viewWillDisappear:(BOOL)animated {
    NSLog(@"in Viewwill Disappear");
    
    if(gTimer) {
        [gTimer invalidate];
        gTimer = nil;
    }
    
}



- (IBAction)backToController:(id)sender {
    //  [self presentViewController:vc animated:YES completion:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(void)updateGraph {
    
    [plutoManager.protocol sendRequestMSP_DEBUG:graphRequests];
   
    [_gyroGraph addX:gyroX y:gyroY z:gyroZ];
    
}



@end
