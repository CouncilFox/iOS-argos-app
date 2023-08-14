//
//  RightJoystickView.m
//  PlutoController
//
//  Created by Drona Aviation on 13/08/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "KAZ_JoystickNode.h"
#import "RightJoystickScene.h"

@interface RightJoystickScene(){
    KAZ_JoystickNode *shootJoystick;
    int lwidth, lheight;
}

@end

@implementation RightJoystickScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor clearColor];
        
        lwidth=self.size.width/2;
        lheight=self.size.height/2;
        
        shootJoystick = [[KAZ_JoystickNode alloc] init];
        shootJoystick.leftJoystick=NO;
        
        [shootJoystick setOuterControl:@"direction_outer_ring" withAlpha:1.0];
        [shootJoystick setInnerControl:@"r2_blue" withAlpha:1.0];
        shootJoystick.movePoints = 501;
        shootJoystick.autoShowHide=NO;
        shootJoystick.alphaHandler=TRUE;
        
        [shootJoystick setXScale:0.42];
        [shootJoystick setYScale:0.42];
        
        shootJoystick.position = CGPointMake(lwidth,lheight);
        
        [self addChild:shootJoystick];
    }
    
    return self;
}

@end
