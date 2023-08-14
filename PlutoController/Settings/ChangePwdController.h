//
//  ChangePwdController.h
//  PlutoController
//
//  Created by Drona Aviation on 28/11/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlutoWifi.h"

@interface ChangePwdController : UIViewController <UITextFieldDelegate> {
    RLMRealm *realm;
}

@end
