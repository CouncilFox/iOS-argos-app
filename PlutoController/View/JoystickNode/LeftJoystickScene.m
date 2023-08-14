//
//  LeftJoystickView.m
//  PlutoController
//
//  Created by Drona Aviation on 13/08/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "Util.h"
#import "KAZ_JoystickNode.h"
#import "LeftJoystickScene.h"

@interface LeftJoystickScene(){
    KAZ_JoystickNode *moveJoystick;
    int lwidth, lheight;
}

@end


@implementation LeftJoystickScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor clearColor];
        
        lwidth=self.size.width/2;
        lheight=self.size.height/2;
        
        moveJoystick = [[KAZ_JoystickNode alloc] init];
        moveJoystick.leftJoystick=YES;
        
        [moveJoystick setOuterControl:@"control_outer_ring-1" withAlpha:1.0];
        [moveJoystick setInnerControl:@"r2_blue" withAlpha:1.0];
        moveJoystick.movePoints = 501;
        moveJoystick.autoShowHide=NO;
        moveJoystick.alphaHandler=TRUE;
        
        [moveJoystick setXScale:0.42];
        [moveJoystick setYScale:0.42];
        moveJoystick.position = CGPointMake(lwidth,lheight);
        
        [self addChild:moveJoystick];
    }
    
    return self;
}

-(void) setInnerControlForAltHoldThrottle {
    if(altholdOrThrottle)
        [moveJoystick setInnerControlForAltHoldThrottle:@"throttle_01" withAlpha:1.0f];
    else
        [moveJoystick setInnerControlForAltHoldThrottle:@"r2_blue" withAlpha:1.0f];
    
    [moveJoystick setInnerControlPosition:altholdOrThrottle];
    [moveJoystick setThrottleModeIcon:altholdOrThrottle];
}

@end

