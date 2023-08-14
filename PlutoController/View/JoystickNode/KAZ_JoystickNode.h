//
//  KAZ_JoystickNode.h
//  VirtualControl
//
//  Created by Kevin Kazmierczak on 10/18/13.
//  Copyright (c) 2013 Kevin Kazmierczak. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface KAZ_JoystickNode : SKSpriteNode

@property (nonatomic, assign) BOOL isMoving;
@property (nonatomic, assign) BOOL autoShowHide;
@property (nonatomic, assign) BOOL leftJoystick;
@property (nonatomic, assign) BOOL alphaHandler;
@property (nonatomic, assign) BOOL isIpad;
@property (nonatomic, assign) CGSize moveSize;
@property (nonatomic, strong) UITouch *startTouch;
@property (nonatomic, assign) float movePoints;
@property (nonatomic, assign) float angle;
@property (nonatomic, assign) float defaultAngle;
@property (nonatomic, assign) float radius;

-(void)setInnerControl:(NSString *)imageName withAlpha:(float)alpha;
-(void)setOuterControl:(NSString *)imageName withAlpha:(float)alpha;
-(void)setInnerControlForAltHoldThrottle:(NSString *)imageName withAlpha:(float)alpha;

-(void)startControlFromTouch:(UITouch *)touch andLocation:(CGPoint)location;
-(void)moveControlToLocation:(UITouch *)touch andLocation:(CGPoint)location;
-(void)mapContolToTilt:(float)roll andPitch:(float)pitch;
-(void)endControl;
-(void)reset;

-(void)setTiltModeIcon : (bool) isTiltMode;
-(void)setThrottleModeIcon : (bool) altholdOrThrottle;
-(void)setInnerControlPosition : (bool) isThrottleMode;

@end
