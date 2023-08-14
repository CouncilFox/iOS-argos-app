//
//  AcceleroController.m
//  PlutoController
//
//  Created by Drona Aviation on 11/10/16.
//  Copyright © 2016 Drona Aviation. All rights reserved.
//

#import "AcceleroController.h"
#import "GraphsController.h"

#import "AcceloGraphView.h"



UIViewController * vc;
UIStoryboard *storyboard;



NSMutableArray *graphRequests;

NSTimer * aTimer;
//MultiWi230 *protocol;

@interface AcceleroController ()

@property (weak, nonatomic) IBOutlet AcceloGraphView *acceloGraph;


@end

@implementation AcceleroController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    graphRequests=[NSMutableArray array];
    
    [graphRequests addObject:[NSNumber numberWithInt:MSP_RAW_IMU]];
    
    [graphRequests addObject:[NSNumber numberWithInt:MSP_ALTITUDE]];
    
    
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    vc = [storyboard instantiateViewControllerWithIdentifier:@"a"];
    
    //   protocol=[[MultiWi230 alloc]init];
    
    //  plutoManager=[PlutoManager sharedManager];
    
    
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
    
    // [accGraphDataThread start];
    
    NSLog(@"in Viewwill Appear");
    
    aTimer=[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateGraph) userInfo:nil repeats:YES];
    
    
}



-(void)viewWillDisappear:(BOOL)animated {
    
    NSLog(@"in Viewwill Disappear");
    
    if(aTimer)
    {
        [aTimer invalidate];
        aTimer = nil;
    }
    
}


- (IBAction)backToController:(id)sender {
    // [self presentViewController:vc animated:YES completion:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(void)updateGraph {
    //   NSLog(@"value of msp raw imu %i",MSP_RAW_IMU);
    
    [plutoManager.protocol sendRequestMSP_DEBUG:graphRequests];
    NSLog(@"######## accX=%f",accX);
    
    NSLog(@"######## accY=%f",accY);
    
    NSLog(@"######## accZ=%f",accZ);
    [_acceloGraph addX:accX y:accY z:accZ];
    
}
@end
