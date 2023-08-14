//
//  FirmwareFlasher.h
//  PlutoController
//
//  Created by Drona Aviation on 12/09/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirmwareFlasher : UIViewController {
    NSMutableArray *blockObjectList;
    bool isValidHexFile;
    NSMutableData *fileData;
    long fileLength;
}

-(void) downloadFirmware: (NSString *) downloadURL and: (NSString *) fileName;

@end
