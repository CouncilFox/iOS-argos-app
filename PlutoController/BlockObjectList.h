//
//  BlockObjectList.h
//  PlutoController
//
//  Created by Drona Aviation on 21/08/17.
//  Copyright © 2017 Drona Aviation. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef BlockObjectList_h
#define BlockObjectList_h

@interface BlockObjectList : NSObject{
    long address;
    long no_bytes;
    NSMutableArray *data;
}

- (void) updateNoOfBytes;

- (void) setAddress : (long) address_to_be_set;

- (void) addData : (int) data_to_be_add;

- (long) getNoOfBytes;

- (long) getAddress;

- (NSMutableArray *) getData;

@end

#endif /* BlockObjectList_h */
