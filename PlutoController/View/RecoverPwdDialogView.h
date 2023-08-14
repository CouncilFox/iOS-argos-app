//
//  RecoverPwdDialogView.h
//  PlutoController
//
//  Created by Drona Aviation on 29/11/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlutoWifi.h"

@interface RecoverPwdDialogView : UIView <UITextFieldDelegate> {
    RLMRealm *realm;
}

@end
