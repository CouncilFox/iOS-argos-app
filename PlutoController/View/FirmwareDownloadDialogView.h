//
//  FirmwareDownloadDialogView.h
//  PlutoController
//
//  Created by Drona Aviation on 06/02/19.
//  Copyright © 2019 Drona Aviation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirmwareFlasher.h"

NS_ASSUME_NONNULL_BEGIN

@interface FirmwareDownloadDialogView : UIView {
    
}

-(void) setFirmwareViewController : (FirmwareFlasher *) viewController;

@end

NS_ASSUME_NONNULL_END
