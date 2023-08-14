//
//  TabBarController.m
//  PlutoController
//
//  Created by Drona Aviation on 07/05/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "TabBarController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.backgroundColor = [UIColor colorWithRed:0.101 green:0.098 blue:0.133 alpha:0.1];
    CGRect frame = self.tabBar.bounds;
    frame.size.height = self.tabBar.bounds.size.height * 2;
    visualEffectView.frame = frame;
    
    [self.tabBar insertSubview:visualEffectView atIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

@end

