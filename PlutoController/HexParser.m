//
//  HexParser.m
//  PlutoController
//
//  Created by Drona Aviation on 21/08/17.
//  Copyright © 2017 Drona Aviation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HexParser.h"
#import "BlockObjectList.h"

@implementation HexParser

-(id) init {
    self=[super init];
    blockObjectList = [NSMutableArray array];
    _isValidHexFile = true;
    endOfFile = false;
    totalBytes = 0;
    nextAddress = 0;
    extendedLinearAddress = 0;
    blockObjectCount = -1;
    return self;
}

- (NSMutableArray *) readHexFile: (NSMutableArray *) hexfile{
    
    if(hexfile.count <= 0) {
        _isValidHexFile = false;
        return nil;
    }
    
    for(int index = 0; index < hexfile.count && _isValidHexFile ; index++){
        NSString *data = [hexfile objectAtIndex:index];
        if(data.length > 0){
            unsigned int byte_count = 0;
            NSScanner *scanner = [NSScanner scannerWithString:[data substringWithRange:NSMakeRange(1,2)]];
            [scanner scanHexInt:&byte_count];
            unsigned int address = 0;
            scanner = [NSScanner scannerWithString:[data substringWithRange:NSMakeRange(3,4)]];
            [scanner scanHexInt:&address];
            unsigned int record_type = 0;
            scanner = [NSScanner scannerWithString:[data substringWithRange:NSMakeRange(7,2)]];
            [scanner scanHexInt:&record_type];
            unsigned int length = (9 + (byte_count * 2)) - 9;
            NSString *data_content = [data substringWithRange:NSMakeRange(9,length)];
            unsigned int checksum = 0;
            length = (9 + (byte_count * 2) + 2) - (9 + (byte_count * 2));
            scanner = [NSScanner scannerWithString:[data substringWithRange:NSMakeRange((9 + (byte_count * 2)),length)]];
            [scanner scanHexInt:&checksum];
            
            switch (record_type) {
                case 0x00: // data record
                {
                    if (address != nextAddress || nextAddress == 0) {
                        [blockObjectList addObject: [[BlockObjectList alloc]init]];
                        blockObjectCount++;
                        BlockObjectList *blockList = [blockObjectList objectAtIndex:blockObjectCount];
                        [blockList setAddress:extendedLinearAddress + address];
                    }
                    
                    // store address for next comparison
                    nextAddress = address + byte_count;
                    
                    // process data
                    unsigned int crc_count = 0;
                    NSScanner *scanner = [NSScanner scannerWithString:[data substringWithRange:NSMakeRange(3,2)]];
                    [scanner scanHexInt:&crc_count];
                    unsigned int crc_count_1 = 0;
                    scanner = [NSScanner scannerWithString:[data substringWithRange:NSMakeRange(5,2)]];
                    [scanner scanHexInt:&crc_count_1];
                    long crc = byte_count + crc_count + crc_count_1 + record_type;
                    for (int needle = 0; needle < byte_count * 2; needle += 2) { // * 2 because of 2 hex chars per 1 byte
                        uint num = 0;
                        length = (needle+2) - needle;
                        NSScanner *scanner = [NSScanner scannerWithString:[data_content substringWithRange:NSMakeRange(needle,length)]];
                        [scanner scanHexInt:&num]; // get one byte in hex and convert it to decimal
                        
                        BlockObjectList *blockList = [blockObjectList objectAtIndex:blockObjectCount];
                        [blockList addData:num];
                        [blockList updateNoOfBytes];
                        
                        crc += num;
                        totalBytes++;
                    }
                    
                    // change crc to 2's complement
                    crc = (~crc + 1) & 0xFF;
                                        
                    // verify
                    if (crc != checksum) {
                        _isValidHexFile = false;
                    }
                    break;
                }
                case 0x01: // end of file record
                    endOfFile = true;
                    break;
                case 0x02: // extended segment address record
                    break;
                case 0x03: // start segment address record
                    break;
                case 0x04: // extended linear address record
                {
                    unsigned int linearAddressPart1 = 0;
                    scanner = [NSScanner scannerWithString:[data_content substringWithRange:NSMakeRange(0,2)]];
                    [scanner scanHexInt:&linearAddressPart1];
                    
                    unsigned int linearAddressPart2 = 0;
                    scanner = [NSScanner scannerWithString:[data_content substringWithRange:NSMakeRange(2,2)]];
                    [scanner scanHexInt:&linearAddressPart2];
                    
                    extendedLinearAddress = (linearAddressPart1 << 24) | linearAddressPart2 << 16;
                    break;
                }
                case 0x05: // start linear address record
                    break;
                default:
                    break;
            }
        }
    }
    
    return blockObjectList;
}

@end
