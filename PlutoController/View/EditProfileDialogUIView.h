//
//  EditProfileDialogUIView.h
//  PlutoController
//
//  Created by Drona Aviation on 30/07/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProfileDialogUIView : UIView <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

-(void) setUser: (User *) user;

-(void) setViewController: (UIViewController *) viewController;

@end
