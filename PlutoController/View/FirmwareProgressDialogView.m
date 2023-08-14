//
//  FirmwareProgressDialogView.m
//  PlutoController
//
//  Created by Drona Aviation on 20/09/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "Util.h"
#import "HexParser.h"
#import "BlockObjectList.h"
#import "FirmwareProgressDialogView.h"
#import "CustomProgressView.h"

@interface FirmwareProgressDialogView()

@property (strong, nonatomic) IBOutlet UIView *firmwareDialogView;
@property (strong, nonatomic) IBOutlet UILabel *uiLabelFirmwarePercentage;

@end

@implementation FirmwareProgressDialogView

NSThread *firmwareFlashThread;
bool isUsingExtendedErase;
int flashProgress = 0;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

-(void) customInit
{
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView;   
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1.0 alpha:0.1];
    visualEffectView.frame = self.bounds;
    [self addSubview:visualEffectView];
    
    [[NSBundle mainBundle] loadNibNamed:@"FirmwareProgressDialog" owner:self options:nil];
    
    [self addSubview:self.firmwareDialogView];
    
    self.firmwareDialogView.frame = CGRectMake(0, 0, self.frame.size.width * 0.73f, self.frame.size.height * 0.65f);
    self.firmwareDialogView.center = CGPointMake(self.frame.size.width * 0.5f, self.frame.size.height * 0.45f);
    
    self.firmwareDialogView.layer.cornerRadius = 7;
    self.firmwareDialogView.layer.masksToBounds = true;
    
    blocks = 0;
    flashing_block = 0;
    address = 0;
    bytes_flashed = 0;
    bytes_flashed_total = 0;
    bytes_total = 0;
    reading_block = 0;
    bytes_verified = 0;
    bytes_verified_total = 0;
    
    firmwareFlashThread=[[NSThread alloc] initWithTarget:self selector:@selector(firmareFlash) object:nil];
    
    [firmwareFlashThread start ];
}

- (IBAction)closeFirmwareProgressDialog:(id)sender {
    [self closeFirmwareProgressDialog];
}

-(void)firmareFlash {
    [plutoManager.protocol removeInputStreamDelegate];
    
    [self setProgress:10];
    [plutoManager.protocol EnableBootMode];
    
    [plutoManager.protocol sendRequestParity:@"E"];
    
    NSLog(@"Checking bootloader status");
    [plutoManager.protocol checkBootLoaderStatus];
    
    [self readDataDuringFlashMode];
    
    while (plutoManager.WiFiConnection.flash_char != 121) {
        if(![self readDataDuringFlashMode])
            return;
    }
    
    [plutoManager.protocol sendFlashCommands: [NSMutableArray arrayWithObjects: [NSNumber numberWithLong:0x00], [NSNumber numberWithLong:0xFF], nil]];
    
    for (int i = 0; i < 15; i++) {
        [self readDataDuringFlashMode];
        
        if(i == 9)
            isUsingExtendedErase = (plutoManager.WiFiConnection.flash_char == 68);
    }
    
    if(plutoManager.WiFiConnection.flash_char == 121) {
        [plutoManager.protocol sendFlashCommands: [NSMutableArray arrayWithObjects: [NSNumber numberWithLong:0x02], [NSNumber numberWithLong:0xFD], nil]];
    } else {
        return;
    }
    
    for (int i = 0; i < 5; i++) {
        [self readDataDuringFlashMode];
    }
    
    if(plutoManager.WiFiConnection.flash_char == 121) {
        [plutoManager.protocol sendFlashCommands: isUsingExtendedErase ? [NSMutableArray arrayWithObjects: [NSNumber numberWithLong:0x44], [NSNumber numberWithLong:0xBB], nil] : [NSMutableArray arrayWithObjects: [NSNumber numberWithLong:0x43], [NSNumber numberWithLong:0xBC], nil]];
    } else {
        return;
    }
    
    [self readDataDuringFlashMode];
    
    if(plutoManager.WiFiConnection.flash_char == 121) {
        [plutoManager.protocol sendFlashCommands: isUsingExtendedErase ? [NSMutableArray arrayWithObjects: [NSNumber numberWithLong:0xFF], [NSNumber numberWithLong:0xFF], [NSNumber numberWithLong:0x00], nil] : [NSMutableArray arrayWithObjects: [NSNumber numberWithLong:0xFF], [NSNumber numberWithLong:0x00], nil]];
        
    } else {
        return;
    }
    
    [self readDataDuringFlashMode];
    
    if(plutoManager.WiFiConnection.flash_char == 121) {
        
        BlockObjectList *blockObject;
        
        self->blocks = self->blockObjectList.count - 1;
        self->flashing_block = 0;
        blockObject = [self->blockObjectList objectAtIndex:self->flashing_block];
        self->address = blockObject.getAddress;
        self->bytes_flashed = 0;
        self->bytes_flashed_total = 0;
        
        for (int i = 0; i <= self->blocks; i++) {
            blockObject = [self->blockObjectList objectAtIndex:i];
            self->bytes_total+= blockObject.getNoOfBytes;
        }
        
        self->wd_call = 1;
        self->wd_execution = 0;
        while (self->wd_call == 1) {
            if([firmwareFlashThread isCancelled])
                return;
            [self writeDataTOFlash];
        }
        
        if (self->wd_execution == 1) {
            [self setProgress:100];
            [self goAndReset];
        }
        
    } else {
        return;
    }
    
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 800 * NSEC_PER_MSEC), dispatch_get_main_queue(),^{
         [self removeFromSuperview];
         
         if(nil != self->viewController)
             [self->viewController dismissViewControllerAnimated:YES completion:nil];
     });
}

- (void) writeDataTOFlash {
    BlockObjectList *blockObject;
    
    if (bytes_flashed < [[blockObjectList objectAtIndex:flashing_block] getNoOfBytes]) {
        
        int bytes_to_write = ((bytes_flashed + 256) <= [[blockObjectList objectAtIndex:flashing_block] getNoOfBytes]) ? 256 : (int) ([[blockObjectList objectAtIndex:flashing_block] getNoOfBytes] - bytes_flashed);
        
        [plutoManager.protocol sendFlashCommands:[NSMutableArray arrayWithObjects:[NSNumber numberWithLong:0x31], [NSNumber numberWithLong:0xCE], nil]];
        
        [self readDataDuringFlashMode];
        
        if(plutoManager.WiFiConnection.flash_char == 121) {
            long address_arr[] = {(address >> 24), (address >> 16), (address >> 8), address};
            long address_checksum = address_arr[0] ^ address_arr[1] ^ address_arr[2] ^ address_arr[3];
            
            [plutoManager.protocol sendFlashCommands:[NSMutableArray arrayWithObjects: [NSNumber numberWithLong:address_arr[0]], [NSNumber numberWithLong:address_arr[1]], [NSNumber numberWithLong:address_arr[2]], [NSNumber numberWithLong:address_arr[3]], [NSNumber numberWithLong:address_checksum], nil]];
            
        } else {
            return;
        }
        
        [self readDataDuringFlashMode];
        
        if(plutoManager.WiFiConnection.flash_char == 121) {
            
            NSMutableArray *array_out = [[NSMutableArray alloc] init];;
            [array_out addObject:[NSNumber numberWithLong:bytes_to_write - 1]];
            
            long checksum = bytes_to_write - 1;
            
            for (int i = 0; i < bytes_to_write; i++) {
                blockObject = [blockObjectList objectAtIndex:flashing_block];
                [[blockObject.getData objectAtIndex:bytes_flashed] longValue];
                [array_out addObject:[blockObject.getData objectAtIndex:bytes_flashed]];
                checksum ^= [[array_out objectAtIndex:(i+1)] longValue];
                bytes_flashed++;
            }
            [array_out addObject:[NSNumber numberWithLong:checksum]];
            
            address += bytes_to_write;
            bytes_flashed_total += bytes_to_write;
            
            [plutoManager.protocol sendFlashCommands:array_out];
        }
        
        [self readDataDuringFlashMode];
        
        if(plutoManager.WiFiConnection.flash_char == 121) {
            wd_call = 1;
            
            flashProgress = ((float) bytes_flashed_total / (float) bytes_total * 90.0f);
            
            [self setProgress: flashProgress + 10];
        } else {
            return;
        }
        
    } else {
        if (flashing_block < blocks) {
            flashing_block++;
            blockObject = [blockObjectList objectAtIndex:flashing_block];
            address = blockObject.getAddress;
            bytes_flashed = 0;
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

-(void) goAndReset {
    [plutoManager.protocol sendFlashCommands:[NSMutableArray arrayWithObjects:[NSNumber numberWithLong:0x21], [NSNumber numberWithLong:0xDE], nil]];
    
    [self readDataDuringFlashMode];
    
    if(plutoManager.WiFiConnection.flash_char == 121) {
        long gt_address = 0x8000000;
        long address[] = {(gt_address >> 24), (gt_address >> 16), (gt_address >> 8), gt_address};
        long address_checksum = address[0] ^ address[1] ^ address[2] ^ address[3];
        
        [plutoManager.protocol sendFlashCommands:[NSMutableArray arrayWithObjects:[NSNumber numberWithLong:address[0]], [NSNumber numberWithLong:address[1]], [NSNumber numberWithLong:address[2]], [NSNumber numberWithLong:address[3]], [NSNumber numberWithLong:address_checksum], nil]];
        
    } else {
        return;
    }
    
    [self readDataDuringFlashMode];
    
    if(plutoManager.WiFiConnection.flash_char == 121) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setProgress:100];
            [self makeToast:@"Firmware Flashed Successfully"];
        });
        
        NSLog(@"Here you go!!");
        
        [plutoManager.protocol sendRequestParity:@"N"];
        [plutoManager.protocol disableBootMode];
        
        [plutoManager.protocol setInputStreamDelegate];
    }
}

-(void) setProgress: (int) progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_uiLabelFirmwarePercentage setText:[NSString stringWithFormat: @"%d %%", progress]];
        [self->_firmwareProgressView setProgress:progress * 0.01];
    });
}

-(void) setBlockObjectList: (NSMutableArray *)blockObjectList1 {
    blockObjectList = [blockObjectList1 mutableCopy];
}

-(void) closeFirmwareProgressDialog {
    [firmwareFlashThread cancel];
    [plutoManager.protocol setInputStreamDelegate];
    [self removeFromSuperview];
}

-(bool) readDataDuringFlashMode {
    if(![firmwareFlashThread isCancelled]) {
        [plutoManager.protocol readDataDuringFlashMode];
        return true;
    }
    return false;
}

-(void) setViewController : (UIViewController *) viewController1 {
    viewController = viewController1;
}

@end
