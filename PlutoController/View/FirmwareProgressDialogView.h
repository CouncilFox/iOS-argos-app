//
//  FirmwareProgressDialogView.h
//  PlutoController
//
//  Created by Drona Aviation on 20/09/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirmwareProgressDialogView : UIView {
    UIViewController *viewController;
    NSMutableArray *blockObjectList;
    long blocks;
    int flashing_block;
    long address;
    int bytes_flashed;
    int bytes_flashed_total;
    int bytes_total;
    int reading_block;
    int bytes_verified;
    int bytes_verified_total; // used for progress bar
    int wd_call, wd_execution;
    int vd_call, vd_execution;
}

@property (strong, nonatomic) IBOutlet UIProgressView *firmwareProgressView;

-(void) setBlockObjectList: (NSMutableArray *)blockObjectList1;
-(void) closeFirmwareProgressDialog;
-(void) setViewController : (UIViewController *) viewController;

@end
