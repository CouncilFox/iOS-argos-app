////
////  GraphsController.m
////  PlutoController
////
////  Created by Drona Aviation on 08/10/16.
////  Copyright © 2016 Drona Aviation. All rights reserved.
////
//
//#import "GraphsController.h"
//
//#import "GraphView.h"
//
//NSThread *updateRCSignalsThread1;
//
//NSMutableArray * data01Array;
//NSMutableArray * data02Array;
//
//
//@interface GraphsController ()
//
//@property (weak, nonatomic) IBOutlet GraphView *acceleroGraph;
//
//@property (weak, nonatomic) IBOutlet UIScrollView *scoller;
//
//@end
//
//@implementation GraphsController
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//    
//    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//    vc = [storyboard instantiateViewControllerWithIdentifier:@"a"];
//    
//    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0 / 60.0];
//    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
//    
//       }
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//    
//   
//}
//- (IBAction)backToController:(id)sender {
//    
//    [self presentViewController:vc animated:YES completion:nil];
//}
//
//
//
//-(void)viewWillAppear:(BOOL)animated
//{
//    
//    
//    
//}
//
///*
//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}
//*/
//- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
//{
//    // Update the accelerometer graph view
//   
//       // [filter addAcceleration:acceleration];
//        [_acceleroGraph addX:acceleration.x y:acceleration.y z:0];
//        //[filtered addX:filter.x y:filter.y z:filter.z];
//    
//    
//}
//
//
//
//
//@end
