//
//  Config.m
//  PlutoController
//
//  Created by Drona Aviation on 16/10/16.
//  Copyright © 2016 Drona Aviation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Config.h"


int altholdOrThrottle=0;
int sensitivity=300;
BOOL flipMode=FALSE;
int controlType=0;
BOOL isHeadFreeMode = FALSE;


@implementation PlutoManager

@synthesize WiFiConnection;
@synthesize protocol;

+ (id)sharedManager {
    static PlutoManager *sharedPlutoManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlutoManager = [[self alloc] init];
    });
    return sharedPlutoManager;
}

- (id)init {
    if (self = [super init]) {
        WiFiConnection=[[WiFiCommunication alloc]init];
        
        [MultiWi230 setWiFiCommunication:WiFiConnection];
        
        protocol=[[MultiWi230 alloc]init];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}


@end
