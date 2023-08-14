//
//  BlockObjectList.m
//  PlutoController
//
//  Created by Drona Aviation on 21/08/17.
//  Copyright © 2017 Drona Aviation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlockObjectList.h"

@implementation BlockObjectList

-(id) init {
    self=[super init];
    address = 0;
    no_bytes = 0;
    data = [NSMutableArray array];
    return self;
}

- (void) updateNoOfBytes{
    no_bytes++;
}

- (void) setAddress : (long) address_to_be_set{
    address = address_to_be_set;
}

- (void) addData : (int) data_to_be_add{
    [data addObject:[NSNumber numberWithInt:data_to_be_add]];
}

- (long) getNoOfBytes{
    return no_bytes;
}

- (long) getAddress{
    return address;
}

- (NSMutableArray *) getData{
    return data;
}

@end
