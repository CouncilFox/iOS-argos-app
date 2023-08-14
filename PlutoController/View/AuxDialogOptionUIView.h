//
//  AuxDialogOptionUIView.h
//  PlutoController
//
//  Created by Drona Aviation on 21/07/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface AuxDialogOptionUIView : UIView

@property bool isAuxDialogViewOpen;

- (void) setViewControllerAndAuxType: (ViewController *) viewController and: (BOOL) isDevModeSelected;

@end
