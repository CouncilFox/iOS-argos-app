//
//  Util.m
//  PlutoController
//
//  Created by Drona Aviation on 14/06/17.
//  Copyright © 2017 Drona Aviation. All rights reserved.
//

#include <ifaddrs.h>
#include <arpa/inet.h>
#import <Foundation/Foundation.h>
#import "Communication.h"
#import "LeweiLib/LWManage.h"
#import "Util.h"

int NONE_COMMAND = 0;
int TAKE_OFF = 1;
int LAND = 2;
int BACK_FLIP = 3;
int FRONT_FLIP = 4;
int RIGHT_FLIP = 5;
int LEFT_FLIP = 6;
bool isTrimSet, isAltitudeSet, isDeveloperModeSensorOn, isGPSModeOn;

@implementation Util : NSObject

+ (BOOL) isConnectedToPlutoWifi{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    BOOL isConnected = false;
    int success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
        if(nil != address && [address length] > 1){
            if([[address substringToIndex: [address length] - 2] isEqualToString:[plutoHOST substringToIndex: [plutoHOST length] - 2]]){
                isConnected = true;
            }
        }
    }
    
    freeifaddrs(interfaces);
    
    return isConnected;
}

+ (float) map:(float)x and :(float)in_min and :(float)in_max and :(float)out_min and :(float)out_max{    
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

+ (BOOL) isCurrentFirmwareMagis {
    if (nil != FLIGHT_CONTROLLER_ID && ([FLIGHT_CONTROLLER_ID isEqualToString:@"MAGIS"] || [FLIGHT_CONTROLLER_ID isEqualToString:@"MAGISX"])) {
        return true;
    }
    
    return false;
}

+ (NSInteger) droneType : (NSUserDefaults*) preferences {
    if (nil != BOARD_ID) {
        int boardId;
        
        if([BOARD_ID isEqualToString:@"PRIMUSX"]) {
            boardId = 1;
        } else if([BOARD_ID isEqualToString:@"PRIMUSV4"]) {
            boardId = 2;
        } else {
            boardId = 0;
        }
        
        [preferences setInteger:boardId forKey:@"default_drone_type"];
    }
    
    return [preferences integerForKey: @"default_drone_type"];
}

+ (id)sharedLeweiLib : (UIImageView *)imgMainView {
    static LWManage *sharedLeweiLib = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(nil != imgMainView)
            sharedLeweiLib = [[LWManage alloc] initWithView:imgMainView SecondView:nil PlaylistTableView:nil User:0x24000];
    });
    return sharedLeweiLib;
}

@end
