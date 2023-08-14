//
//  KAZ_MyScene.h
//  VirtualControl
//

//  Copyright (c) 2013 Kevin Kazmierczak. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

extern int lwidth;
extern int lheight;

extern int rwidth;
extern int rheight;

extern float tiltRoll;
extern float tiltPitch;

extern int clwidth;
extern int clheight;

extern int crwidth;
extern int crheight;


@interface KAZ_DynamicControllerScene : SKScene
    -(void) setInnerControlForAltHoldThrottle;


@end
