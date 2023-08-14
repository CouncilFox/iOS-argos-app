
//
//  FirmwareFlasherController.m
//  PlutoController
//
//  Created by Drona Aviation on 03/10/16.
//  Copyright © 2016 Drona Aviation. All rights reserved.
//

#import "FirmwareFlasherController.h"
#import "HexParser.h"
#import "MBProgressHUD.h"
#import "UIView+Toast.h"
#import "Config.h"
#import "BlockObjectList.h"

@interface FirmwareFlasherController () <UIDocumentMenuDelegate, UIDocumentPickerDelegate>
@property (strong, nonatomic) MBProgressHUD *hud;
@property (weak, nonatomic) IBOutlet UIButton *btnFirmareSelect;
@end

@implementation FirmwareFlasherController

NSTimer *timer;
NSMutableArray *blockObjectList;
bool isValidHexFile = false;
int cx;
int counter = 0;
Byte c;
int just_sake = 0;
long blocks = 0;
int flashing_block = 0;
long address = 0;
int bytes_flashed = 0;
int bytes_flashed_total = 0;
int bytes_total = 0;
int reading_block = 0;
int bytes_verified = 0;
int bytes_verified_total = 0; // used for progress bar
int wd_call, wd_execution;
int vd_call, vd_execution;
NSMutableArray *flashCommandsArray;
NSNumber *num1;
NSNumber *num2;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    vc = [storyboard instantiateViewControllerWithIdentifier:@"Settings"];
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

-(void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker{
    documentPicker.delegate = self;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    if (controller.documentPickerMode == UIDocumentPickerModeImport) {
        NSString* fileContents = [NSString stringWithContentsOfURL: url
                                                          encoding:NSUTF8StringEncoding
                                                             error:nil];
        NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];
        NSLog(@"Lines size: %lu", (unsigned long)lines.count);
        _hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        _hud.mode= MBProgressHUDModeIndeterminate;
        _hud.label.text=@"Reading Hex File";
        
        blockObjectList = [[[HexParser alloc] init] readHexFile:[lines mutableCopy]];
        [_hud hideAnimated:YES];
        isValidHexFile = true;
    }
}


- (IBAction)firmareSelect:(id)sender {
    UIDocumentMenuViewController *importMenu =
    [[UIDocumentMenuViewController alloc] initWithDocumentTypes:@[@"public.data"]
                                                         inMode:UIDocumentPickerModeImport];
    
    importMenu.delegate = self;
    [self presentViewController:importMenu animated:YES completion:nil];
}

- (IBAction)firmareFlash:(id)sender {
    if (isValidHexFile) {
        if (plutoManager.WiFiConnection.connected) {
            [plutoManager.protocol EnableBootMode];
            
            usleep(500000);
            
            [plutoManager.protocol sendRequestParity:@"E"];
            
            usleep(500000);
            
            NSLog(@"Checking bootloader status");
            [plutoManager.protocol checkBootLoaderStatus];
            
            NSLog(@"Checking bootloader status2");
            
            NSLog(@"Flash-Response: %d", cx);
            
            sleep(1);
            
            
            if (plutoManager.WiFiConnection.flash_char == 121) {
                cx = 0;
                num1 = [NSNumber numberWithLong:0x00];
                num2 = [NSNumber numberWithLong:0xFF];
                flashCommandsArray = [NSMutableArray arrayWithObjects:num1, num2, nil];
                [plutoManager.protocol sendFlashCommands:flashCommandsArray];
                
                NSLog(@"Checking bootloader status3");
                c = MultiWi230.read8;
                
                NSLog(@"Checking bootloader status4");
                for (int i = 0; i < 14; i++) {
                    c = MultiWi230.read8;
                }
                
                NSLog(@"Checking bootloader status5");
                
                cx = (int) c;
                counter++;
            } else {
                return;
            }
            
            if (plutoManager.WiFiConnection.flash_char == 121) {
                cx = 0;
                num1 = [NSNumber numberWithLong:0x02];
                num2 = [NSNumber numberWithLong:0xFD];
                flashCommandsArray = [NSMutableArray arrayWithObjects:num1, num2, nil];
                [plutoManager.protocol sendFlashCommands:flashCommandsArray];
                
                NSLog(@"Checking bootloader status6");
                c = MultiWi230.read8;
                for (int i = 0; i < 4; i++)
                    c = MultiWi230.read8;
                cx = (int) c;
                counter++;
            }
            
            cx = 0;
            NSLog(@"Checking bootloader status7");
            num1 = [NSNumber numberWithLong:0x43];
            num2 = [NSNumber numberWithLong:0xBC];
            flashCommandsArray = [NSMutableArray arrayWithObjects:num1, num2, nil];
            [plutoManager.protocol sendFlashCommands:flashCommandsArray];
            c = MultiWi230.read8;
            cx = (int) c;
            counter++;
            
            cx = 0;
            num1 = [NSNumber numberWithLong:0xFF];
            num2 = [NSNumber numberWithLong:0x00];
            flashCommandsArray = [NSMutableArray arrayWithObjects:num1, num2, nil];
            [plutoManager.protocol sendFlashCommands:flashCommandsArray];
            NSLog(@"Checking bootloader status8");
            c = MultiWi230.read8;
            cx = (int) c;
            counter = 0;
           
            BlockObjectList *blockObject;
            NSLog(@"Checking bootloader status9");
            blocks = blockObjectList.count - 1;
            flashing_block = 0;
            blockObject = [blockObjectList objectAtIndex:flashing_block];
            address = blockObject.getAddress;
            bytes_flashed = 0;
            bytes_flashed_total = 0;
            just_sake = 0;
            
            for (int i = 0; i <= blocks; i++) {
                blockObject = [blockObjectList objectAtIndex:i];
                bytes_total+= blockObject.getNoOfBytes;
            }
            
            wd_call = 1;
            wd_execution = 0;
                [self writeDataTOFlash];
            
            if (wd_execution == 1) {
                vd_call = 1;
                vd_execution = 0;
                
                while (vd_call == 1)
                    [self verifyFlashedData];
                
                if (vd_execution == 1)
                    [self goAndReset];
            }
            
            if (cx == 121) {
                counter++;
            }
        } else {
            [self.view makeToast:@"Raven is not connected, please reconnect"];
        }
    } else {
        [self.view makeToast:@"Please select valid Firmware Hex file"];
    }
}

- (IBAction)backToSettings:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) writeDataTOFlash {
    BlockObjectList *blockObject;
    [blockObjectList objectAtIndex:flashing_block];
    if (bytes_flashed < [[blockObjectList objectAtIndex:flashing_block] getNoOfBytes]) {
        int bytes_to_write = ((bytes_flashed + 256) <= [[blockObjectList objectAtIndex:flashing_block] getNoOfBytes]) ? 256 : (int) ([[blockObjectList objectAtIndex:flashing_block] getNoOfBytes] - bytes_flashed);
        num1 = [NSNumber numberWithLong:0x31];
        num2 = [NSNumber numberWithLong:0xCE];
        flashCommandsArray = [NSMutableArray arrayWithObjects:num1, num2, nil];
        [plutoManager.protocol sendFlashCommands:flashCommandsArray];
        
        c = MultiWi230.read8;
        cx = (int) c;
        
        NSLog(@"FirmwareFlasher check1");
        counter = 1;
        NSLog(@"FirmwareFlasher response %d", cx);
        
        //if (cx == 121) {
        long address_arr[] = {(address >> 24), (address >> 16), (address >> 8), address};
        long address_checksum = address_arr[0] ^ address_arr[1] ^ address_arr[2] ^ address_arr[3];
        
        num1 = [NSNumber numberWithLong:address_arr[0]];
        num2 = [NSNumber numberWithLong:address_arr[1]];
        NSNumber *num3 = [NSNumber numberWithLong:address_arr[3]];
        NSNumber *num4 = [NSNumber numberWithLong:address_checksum];
        flashCommandsArray = [NSMutableArray arrayWithObjects:num1, num2, num3, num4, nil];
        [plutoManager.protocol sendFlashCommands:flashCommandsArray];
        c = MultiWi230.read8;
        cx = (int) c;
        NSLog(@"FirmwareFlasher check2");
        counter = cx;
        NSLog(@"FirmwareFlasher response %d", cx);
        //if (cx == 121) {
        NSMutableArray *array_out = [[NSMutableArray alloc] init];;
        //long array_out[bytes_to_write + 2]; // 2 byte overhead [N, ...., checksum]
        [array_out addObject:[NSNumber numberWithLong:bytes_to_write - 1]];
        // number of bytes to be written (to write 128 bytes, N must be 127, to write 256 bytes, N must be 255)
        
        long checksum = bytes_to_write - 1;
        counter = 3;
        
        for (int i = 0; i < bytes_to_write; i++) {
            blockObject = [blockObjectList objectAtIndex:flashing_block];
            [[blockObject.getData objectAtIndex:bytes_flashed] longValue];
            [array_out addObject:[blockObject.getData objectAtIndex:bytes_flashed]];
            checksum ^= [[array_out objectAtIndex:(i+1)] longValue];
            bytes_flashed++;
        }
        counter = 4;
        [array_out addObject:[NSNumber numberWithLong:checksum]];// checksum (last byte in the array_out array)
        
        address += bytes_to_write;
        bytes_flashed_total += bytes_to_write;
        
        [plutoManager.protocol sendFlashCommands:array_out];
        c = MultiWi230.read8;
        
        cx = (int) c;
        NSLog(@"FirmwareFlasher check3");
        counter = 5;
        NSLog(@"FirmwareFlasher response %d", cx);
        if (cx == 121) {
            NSLog(@"FirmwareFlasher check4");
            counter = 6;
            wd_call = 1;
            
            //progress = (float) bytes_flashed_total / (float) bytes_total;
            //progress *= 40;
            
            //progressDialog.setProgress((int) (progress + 10));
        }
        //}
        //}
        
    } else {
        if (flashing_block < blocks) {
            flashing_block++;
            blockObject = [blockObjectList objectAtIndex:flashing_block];
            address = blockObject.getAddress;
            bytes_flashed = 0;
            NSLog(@"FirmwareFlasher check5");
            counter = 7;
            wd_call = 1;
        } else {
            blocks = [blockObjectList count] - 1;
            reading_block = 0;
            blockObject = [blockObjectList objectAtIndex:reading_block];
            address = blockObject.getAddress;
            bytes_verified = 0;
            bytes_verified_total = 0; // used for progress bar
            wd_call = 0;
            wd_execution = 1;
        }
    }
}

-(void) verifyFlashedData {
    BlockObjectList *blockObject;
    blockObject = [blockObjectList objectAtIndex:reading_block];
    if (bytes_verified < [blockObject getNoOfBytes]) {
        int bytes_to_read = ((bytes_verified + 256) <= [blockObject getNoOfBytes] ? 256 : (int)[blockObject getNoOfBytes] - bytes_verified);
        num1 = [NSNumber numberWithLong:0x11];
        num2 = [NSNumber numberWithLong:0xEE];
        flashCommandsArray = [NSMutableArray arrayWithObjects:num1, num2, nil];
        [plutoManager.protocol sendFlashCommands:flashCommandsArray];
        cx = (int) MultiWi230.read8;
        if (cx == 121) {
            long address_arr[] = {(address >> 24), (address >> 16), (address >> 8), address};
            long address_checksum = address_arr[0] ^ address_arr[1] ^ address_arr[2] ^ address_arr[3];
            
            num1 = [NSNumber numberWithLong:address_arr[0]];
            num2 = [NSNumber numberWithLong:address_arr[1]];
            NSNumber *num3 = [NSNumber numberWithLong:address_arr[2]];
            NSNumber *num4 = [NSNumber numberWithLong:address_arr[3]];
            NSNumber *num5 = [NSNumber numberWithLong:address_checksum];
            
            flashCommandsArray = [NSMutableArray arrayWithObjects:num1, num2, num3, num4, num5, nil];
            [plutoManager.protocol sendFlashCommands:flashCommandsArray];
            
            cx = (int) MultiWi230.read8;
            //if (cx == 121) {
            long bytes_to_read_n = bytes_to_read - 1;
            
            num3 = [NSNumber numberWithLong:bytes_to_read_n];
            num4 = [NSNumber numberWithLong:(~bytes_to_read_n) & 0xFF];
            
            flashCommandsArray = [NSMutableArray arrayWithObjects:num3, num4, nil];
            [plutoManager.protocol sendFlashCommands:flashCommandsArray];
            cx = (int) MultiWi230.read8;
            //if (cx == 121) {
                
                for (int i = 0; i < bytes_to_read; i++) {
                    int num = (int) MultiWi230.read8; // get one byte in hex and convert it to decimal
                    
                    blockObject = [blockObjectList objectAtIndex:reading_block];
                    [blockObject addData:num];
                    bytes_verified++;
                }
                address += bytes_to_read;
                bytes_verified_total += bytes_to_read;
                
                vd_call = 1;
                //progress = (float) bytes_verified_total / (float) bytes_total;
                //progress *= 40;
                //progressDialog.setProgress((int) (progress + 50));
            //}
            //}
        }
    } else {
        if (reading_block < blocks) {
            reading_block++;
            
            blockObject = [blockObjectList objectAtIndex:reading_block];
            address = blockObject.getAddress;
            bytes_verified = 0;
            vd_call = 1;
        } else {
            bool verify = true;
            for (int i = 0; i <= blocks; i++) {
                for (int j = 0; j < [[blockObjectList objectAtIndex:i] getNoOfBytes]; j++) {
                    //if (!(blockObjectsList.get(i).getData().get(j).equals(blockObjectsList.get(i).getData().get(j)))) {
                    //verify = false;
                    break;
                    //}
                }
                if (!verify) break;
            }
            
            if (verify) {
                [self.view makeToast:@"Firmware Flashed Successfully"];
                vd_call = 0;
                vd_execution = 1;
            } else {
                [self.view makeToast:@"Firmware Flashed Went Wrong"];
            }
        }
        
    }
    
}

-(void) goAndReset {
    num1 = [NSNumber numberWithLong:0x21];
    num1 = [NSNumber numberWithLong:0xDE];
    
    flashCommandsArray = [NSMutableArray arrayWithObjects:num1, num2, nil];
    [plutoManager.protocol sendFlashCommands:flashCommandsArray];
    cx = (int) MultiWi230.read8;
    //if (cx == 121) {
    long gt_address = 0x8000000;
    long address[] = {(gt_address >> 24), (gt_address >> 16), (gt_address >> 8), gt_address};
    long address_checksum = address[0] ^ address[1] ^ address[2] ^ address[3];
    num1 = [NSNumber numberWithLong:address[0]];
    num1 = [NSNumber numberWithLong: address[1]];
    NSNumber *num3 = [NSNumber numberWithLong:address[2]];
    NSNumber *num4 = [NSNumber numberWithLong:address[3]];
    NSNumber *num5 = [NSNumber numberWithLong:address_checksum];
    
    flashCommandsArray = [NSMutableArray arrayWithObjects:num1, num2, num3, num4, num5, nil];
    cx = (int) MultiWi230.read8;
    if (cx == 121) {
        [self.view makeToast:@"Here you go!!"];
        
        [plutoManager.protocol sendRequestParity:@"N"];
        [plutoManager.protocol disableBootMode];
    }
    
    //}
    
}


@end
