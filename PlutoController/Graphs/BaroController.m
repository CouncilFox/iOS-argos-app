//
//  BaroController.m
//  PlutoController
//
//  Created by Drona Aviation on 11/10/16.
//  Copyright © 2016 Drona Aviation. All rights reserved.
//

#import "BaroController.h"
#import "GraphsController.h"
#import "BaroGraphView.h"
#import "AcceloGraphView.h"
#import "AcceleroController.h"

NSTimer * bTimer;

@interface BaroController ()
@property (weak, nonatomic) IBOutlet BaroGraphView *baroGraph;
@property (weak, nonatomic) IBOutlet AcceloGraphView *magtemp;

@end

@implementation BaroController

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
    
    bTimer=[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateGraph) userInfo:nil repeats:YES];
    
}



-(void)viewWillDisappear:(BOOL)animated {
    NSLog(@"in Viewwill Disappear");
    
    if(bTimer) {
        [bTimer invalidate];
        bTimer = nil;
    }
    
}

-(void)updateGraph {
    
    [plutoManager.protocol sendRequestMSP_DEBUG:graphRequests];
    
    NSLog(@"######## Altitude=%f",alt);
    [_baroGraph addX:alt y:0.0 z:0.0];
    [_magtemp addX:alt y:500 z:500];
}
- (IBAction)backToController:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
