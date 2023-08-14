//
//  HexParser.h
//  PlutoController
//
//  Created by Drona Aviation on 21/08/17.
//  Copyright © 2017 Drona Aviation. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef HexParser_h
#define HexParser_h

@interface HexParser :NSObject{
    NSMutableArray *blockObjectList;
    bool endOfFile;
    long totalBytes;
    long nextAddress;
    long extendedLinearAddress;
    int blockObjectCount;
}

- (NSMutableArray *) readHexFile: (NSMutableArray *) hexfile;
@property bool isValidHexFile;

@end

#endif /* HexParser_h */
