//
//  KAZ_MyScene.m
//  VirtualControl
//
//  Created by Kevin Kazmierczak on 10/18/13.
//  Copyright (c) 2013 Kevin Kazmierczak. All rights reserved.
//

#import "KAZ_DynamicControllerScene.h"
#import "KAZ_JoystickNode.h"
#import "RCSingnals.h"
#import "ViewController.h"
#import "Config.h"
#import "Util.h"

int lwidth=0;
int lheight=0;

int rwidth=0;
int rheight=0;

int clwidth=0;
int clheight=0;

int crwidth=0;
int crheight=0;

float tiltRoll=0;
float tiltPitch=0;

@interface KAZ_DynamicControllerScene(){
    
    SKNode *control;
    SKSpriteNode *sprite;
    UITouch *joystickTouch;
    CGPoint touchPoint;
    CGSize move;
    SKSpriteNode *backgroundTexture;
    
    KAZ_JoystickNode *moveJoystick;
    KAZ_JoystickNode *shootJoystick;
    CFTimeInterval lastUpdate;
}

@end

RCSignals *remoteControl;


@implementation KAZ_DynamicControllerScene


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.scaleMode = SKSceneScaleModeFill;
        
        self.backgroundColor = [SKColor clearColor];
        
        lwidth = self.size.width/4.3;
        lheight = self.size.height/2 - 24;
        
        rwidth = self.size.width - self.size.width/4.3;
        rheight = self.size.height/2 - 24;
        
        moveJoystick = [[KAZ_JoystickNode alloc] init];
        moveJoystick.leftJoystick=YES;
        
        [moveJoystick setOuterControl:@"control_outer_ring-1" withAlpha:1.0];
        [moveJoystick setInnerControl:@"r2_blue" withAlpha:1.0];
        moveJoystick.movePoints = 501;
        moveJoystick.autoShowHide=NO;
        moveJoystick.alphaHandler=TRUE;
        
        [moveJoystick setYScale:0.38];
        [moveJoystick setXScale:0.38];
        
        shootJoystick = [[KAZ_JoystickNode alloc] init];
        [shootJoystick setOuterControl:@"direction_outer_ring" withAlpha:1.0];
        [shootJoystick setInnerControl:@"r2_blue" withAlpha:1.0];
        
        shootJoystick.movePoints = [Util map:sensitivity and:300 and:500 and:501 and:401];
        
        [shootJoystick setXScale:0.38];
        [shootJoystick setYScale:0.38];
        
        shootJoystick.autoShowHide=NO;
        shootJoystick.alphaHandler=TRUE;
        
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            
            [moveJoystick setYScale:0.22];
            [moveJoystick setXScale:0.22];
            
            [shootJoystick setXScale:0.22];
            [shootJoystick setYScale:0.22];
            
            moveJoystick.position = CGPointMake(lwidth + 26, lheight - 60);
            shootJoystick.position = CGPointMake(rwidth - 26, rheight - 60);
            
            clwidth = lwidth + 26;
            clheight = lheight - 60;
            
            crwidth = rwidth + 26;
            crheight = rheight - 60;
        }
        
        else {
            moveJoystick.position = CGPointMake(lwidth, lheight);
            shootJoystick.position = CGPointMake(rwidth, rheight);
            
            clwidth=lwidth;
            clheight=lheight;
            
            crwidth=rwidth;
            crheight=rheight;
        }
        
        [self addChild:moveJoystick];
        [self addChild:shootJoystick];
    }
        
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        if(location.y < self.size.height - 60) {
            if ( location.x < self.size.width / 2 ){
                if(location.x>clwidth- moveJoystick.radius && location.x<clwidth+ moveJoystick.radius && location.y>clheight- moveJoystick.radius && location.y<clheight+ moveJoystick.radius)
                    
                        [moveJoystick startControlFromTouch:touch andLocation:location];
            }
            else {
                if(location.x>crwidth- shootJoystick.radius && location.x<crwidth+ shootJoystick.radius && location.y>crheight- shootJoystick.radius && location.y<crheight+ shootJoystick.radius)
                
                        [shootJoystick startControlFromTouch:touch andLocation:location];
            }
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches) {
        if ( touch == moveJoystick.startTouch){
            [moveJoystick moveControlToLocation:touch andLocation:[touch locationInNode:self]];
        }
        else {
            if ( touch == shootJoystick.startTouch){
                [shootJoystick moveControlToLocation:touch andLocation:[touch locationInNode:self]];
            }
            
        }
        
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches) {
        if ( touch == moveJoystick.startTouch){
            [moveJoystick endControl];
        }
        else if ( touch == shootJoystick.startTouch){
            [shootJoystick endControl];
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    
    // Shoot bullets every half second
    if ( currentTime - lastUpdate >= 0.1 ){
        lastUpdate = currentTime;
    }
    
    if ( moveJoystick.isMoving ){
        CGPoint adjustedSpritePosition = CGPointMake(sprite.position.x + moveJoystick.moveSize.width, sprite.position.y + moveJoystick.moveSize.height);
        if ( adjustedSpritePosition.x < 0 ){
            adjustedSpritePosition.x = 0;
        } else if ( adjustedSpritePosition.x > self.size.width ){
            adjustedSpritePosition.x = self.size.width;
        }
        if ( adjustedSpritePosition.y < 0 ){
            adjustedSpritePosition.y = 0;
        } else if ( adjustedSpritePosition.y > self.size.height ){
            adjustedSpritePosition.y = self.size.height;
        }
        
    }

//    int setYaw;
//
//    if (moveJoystick.moveSize.width > 0) {
//        setYaw = (int) pow(1.0814, moveJoystick.moveSize.width);
//    } else {
//        setYaw = (int) pow(1.0814, (-moveJoystick.moveSize.width));
//        setYaw = -setYaw;
//    }
    
    [[ViewController getRemoteController]setYaw:(moveJoystick.moveSize.width+1500)];
    [[ViewController getRemoteController] setThrottle:(moveJoystick.moveSize.height+1500)];

    if(!controlType) {
        if(shootJoystick.isMoving){
            [[ViewController getRemoteController]setRoll:(shootJoystick.moveSize.width+1500)];
            [[ViewController getRemoteController]setPitch:(shootJoystick.moveSize.height+1500)];
        }
        else {
            [[ViewController getRemoteController]setRoll:(shootJoystick.moveSize.width+1500)];
            [[ViewController getRemoteController] setPitch:(shootJoystick.moveSize.height+1500)];
        }
    }
    else {
        
        [shootJoystick mapContolToTilt:tiltPitch andPitch:tiltRoll];
        
        [[ViewController getRemoteController]setRoll:(int)([Util map:(tiltPitch*10) and:-920 and:920 and:-sensitivity and:sensitivity])+1500];
        [[ViewController getRemoteController]setPitch:(int)([Util map:(tiltRoll*10) and:-920 and:920 and:-sensitivity and:sensitivity])+1500];
    }
    
    [shootJoystick setTiltModeIcon:controlType];
}

-(void) setInnerControlForAltHoldThrottle {
    if(altholdOrThrottle) {
        [moveJoystick setInnerControlForAltHoldThrottle:@"throttle_01" withAlpha:1.0f];
    }
    else {
        [moveJoystick setInnerControlForAltHoldThrottle:@"r2_blue" withAlpha:1.0f];
    }
    
    [moveJoystick setInnerControlPosition:altholdOrThrottle];
    [moveJoystick setThrottleModeIcon:altholdOrThrottle];
}

@end

