//
//  KAZ_JoystickNode.m
//  VirtualControl
//
//  Created by Kevin Kazmierczak on 10/18/13.
//  Copyright (c) 2013 Kevin Kazmierczak. All rights reserved.
//

#import "KAZ_JoystickNode.h"
#import "KAZ_DynamicControllerScene.h"
#import "Config.h"

@interface KAZ_JoystickNode(){
    SKSpriteNode *outerControl;
    SKSpriteNode *innerControl;
    SKSpriteNode *innerControlThrottle;
    SKSpriteNode *directionLeft;
    SKSpriteNode *directionRight;
    SKSpriteNode *directionTop;
    SKSpriteNode *directionDown;
    SKSpriteNode *throttleLines;
    SKSpriteNode *tiltModeIcon;
    CGPoint startPoint;
}

@end

float outerRadius=0;

@implementation KAZ_JoystickNode

-(id)init{
    
    self = [super init];
    if (self){
        //self.autoShowHide = YES;
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            self.isIpad=YES;
        }
        else {
            self.isIpad=NO;
        }
    }
    return self;
}

-(void)setDefaultAngle:(float)defaultAngle{
    _defaultAngle = defaultAngle;
    self.angle = _defaultAngle;
    
}

-(void)setAutoShowHide:(BOOL)autoShowHide{
    _autoShowHide = autoShowHide;
    if ( _autoShowHide ){
        self.alpha = 0;
    }
    else {
        self.alpha = 1;
    }
}

-(void)setInnerControl:(NSString *)imageName withAlpha:(float)alpha{
    if (innerControl){
        [innerControl removeFromParent];
    }
    
    innerControl = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    innerControl.alpha = alpha;
    [self addChild:innerControl];
    
    if(!_leftJoystick) {
        tiltModeIcon = [SKSpriteNode spriteNodeWithImageNamed:@"ic_tilt_mode"];
        tiltModeIcon.position = CGPointMake(self.frame.origin.x * 0.5 , self.frame.origin.y * 0.5);
        tiltModeIcon.alpha = 0;
        [tiltModeIcon setSize:CGSizeMake(innerControl.frame.size.width * 0.5, innerControl.frame.size.width * 0.5)];
        [self addChild:tiltModeIcon];
    }
}

-(void)setInnerControlForAltHoldThrottle:(NSString *)imageName withAlpha:(float)alpha{
    if (innerControl){
        [innerControl removeFromParent];
    }
    
    innerControl = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    innerControl.alpha = alpha;
    [self addChild:innerControl];
}

-(void)setOuterControl:(NSString *)imageName withAlpha:(float)alpha{
    if (outerControl)
        [outerControl removeFromParent];
    
    outerControl = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    outerControl.alpha = alpha;
    [self addChild:outerControl];
    
    _radius = (outerControl.size.width / 2) * 0.35;
    
    if(_leftJoystick){
        directionTop = [SKSpriteNode spriteNodeWithImageNamed:@"Up"];
        directionTop.position = CGPointMake(0 , outerControl.size.height * 0.5 - 52);
        [self addChild:directionTop];
        
        directionLeft = [SKSpriteNode spriteNodeWithImageNamed:@"Left"];
        directionLeft.position = CGPointMake(-outerControl.size.width * 0.5 + 52 , 0);
        [self addChild:directionLeft];
        
        directionRight = [SKSpriteNode spriteNodeWithImageNamed:@"Right"];
        directionRight.position = CGPointMake(outerControl.size.width * 0.5 - 52 , 0);
        [self addChild:directionRight];
        
        directionDown = [SKSpriteNode spriteNodeWithImageNamed:@"Down"];
        directionDown.position = CGPointMake(0, -outerControl.size.height * 0.5 + 52);
        [self addChild:directionDown];
        
        throttleLines = [SKSpriteNode spriteNodeWithImageNamed:@"ic_throttle_lines"];
        throttleLines.position = CGPointMake(0, 0);
        [throttleLines setSize:CGSizeMake(throttleLines.frame.size.width, outerControl.size.height * 0.52f)];
        throttleLines.alpha = 0;
        [self addChild:throttleLines];
    }
}


-(void)startControlFromTouch:(UITouch *)touch andLocation:(CGPoint)location{
    if ( self.autoShowHide ){
        self.alpha = 1;
        self.position = location;
    }
    self.startTouch = touch;
    startPoint = location;
    self.isMoving = YES;
}

-(void)moveControlToLocation:(UITouch *)touch andLocation:(CGPoint)location{
    // Get the outer ring radius
    
    if(altholdOrThrottle)
        outerRadius = (outerControl.size.width / 2) * 0.35;
    else
        outerRadius = (outerControl.size.width / 2) * 0.50;
    
    float movePoints = self.movePoints;
    // Get the change in X
    float deltaX = location.x - startPoint.x;
    // Get the change in Y
    float deltaY = location.y - startPoint.y;
    // Calculate the distance the stick is from the center point
    float distance = sqrtf((deltaX * deltaX) + (deltaY * deltaY));
    // Get the angle of movement
    self.angle = atan2f(deltaY, deltaX) * 180 / M_PI;
    // Is it moving left?
    BOOL isLeft = ABS(self.angle) > 90;
    // Convert the angle to radians
    float radians = self.angle * M_PI / 180;

    CGPoint position = [touch locationInNode:self];
    
    if(distance > outerRadius || fabs(position.x) > outerRadius || fabs(position.y) > outerRadius) {
        
        float maxY = outerRadius * sinf(radians);
        float maxX = sqrtf((outerRadius * outerRadius) - (maxY * maxY));
        if (isLeft) {
            maxX *= -1;
        }
        
        innerControl.position = CGPointMake(maxX, maxY);
        movePoints = self.movePoints;
    }
    
    else {
        // If the distance is less than the radius, it moves freely
        
        innerControl.position = [touch locationInNode:self];
        movePoints = distance / outerRadius * self.movePoints;
    }
    
    // Calculate Y Movement
    float moveY = movePoints * sinf(radians);
    // Calculate X Movement
    float moveX = sqrtf(( movePoints * movePoints ) - ( moveY * moveY ) );
    // Adjust if it's going left
    if ( isLeft ){
        moveX *= -1;
    }
    
    self.moveSize = CGSizeMake(moveX, moveY);
}

-(void)endControl{
    self.isMoving = NO;
    [self reset];
}

-(void)reset{
    
    if(self.leftJoystick) {
        
        if(!self.isIpad) {
            self.position=CGPointMake(lwidth, lheight);
        }
        else {
            self.position=CGPointMake(lwidth + 26, lheight - 60);
        }
        
        if(!altholdOrThrottle) {
            innerControl.position = CGPointMake(0, 0);
            self.moveSize = CGSizeMake(0, 0);
        }
        else {
            float inY=innerControl.position.y;
            float moY=self.moveSize.height;
            
            innerControl.position = CGPointMake(0, inY);
            self.moveSize = CGSizeMake(0, moY);
        }
        
    }
    
    else {
        self.moveSize = CGSizeMake(0, 0);
        self.angle = self.defaultAngle;
        innerControl.position = CGPointMake(0, 0);
        
        if(!self.isIpad) {
            self.position=CGPointMake(rwidth, rheight);
        }
        else {
            self.position=CGPointMake(rwidth - 26, rheight - 60);
        }
        
    }
}

-(void)mapContolToTilt:(float)roll andPitch:(float)pitch {
    innerControl.position= CGPointMake(roll, pitch);
}

-(void)setTiltModeIcon : (bool) isTiltMode {
    [tiltModeIcon setAlpha: isTiltMode];
}

-(void)setThrottleModeIcon : (bool) altholdOrThrottle {
    [throttleLines setAlpha: altholdOrThrottle];
}

-(void)setInnerControlPosition : (bool) isThrottleMode {
    if(isThrottleMode)
        innerControl.position = CGPointMake(0, -(outerControl.size.width / 2) * 0.65);
    else
        innerControl.position = CGPointMake(0, 0);
}

@end
