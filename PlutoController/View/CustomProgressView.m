//
//  CustomProgressView.m
//  PlutoController
//
//  Created by Drona Aviation on 03/07/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "CustomProgressView.h"

@implementation CustomProgressView

CAGradientLayer *gradient;
int progressGradient;

- (CGRect)trackRectForBounds:(CGRect)bounds {
    CGRect frame = CGRectMake(0, 0, self.bounds.size.width, 6);
    frame.origin.y = (self.bounds.size.height * 0.5) - 3;
    CGRect rect = frame;
    return rect;
}

-(void)setProgress:(float)progress {
    CGRect frame = CGRectMake(0, 0, progressGradient * progress, 12);
    frame.origin.y = (self.bounds.size.height * 0.5) - 3;
    gradient.frame = frame;
}

-(void) setGradient {
    progressGradient = self.bounds.size.width;
    
    CALayer *backgroundLayer = [CALayer layer];
    
    CGRect backgroundLayerFrame = CGRectMake(0, 0, self.bounds.size.width, 12);
    backgroundLayerFrame.origin.y = (self.bounds.size.height * 0.5) - 3;
    backgroundLayer.frame = backgroundLayerFrame;
    backgroundLayer.cornerRadius = 6;
    backgroundLayer.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f].CGColor;
    [self.layer insertSublayer:backgroundLayer atIndex:1];
    
    gradient = [CAGradientLayer layer];
    CGRect frame = CGRectMake(0, 0, 0, 12);
    frame.origin.y = (self.bounds.size.height * 0.5) - 3;
    gradient.frame = frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.07 green:0.867  blue:1.0 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:0.07 green:0.40 blue:1.0 alpha:1.0] CGColor], nil];
    gradient.cornerRadius = 6;
    gradient.startPoint = CGPointMake(0, 0.6);
    gradient.endPoint = CGPointMake(1, 0.4);
    [self.layer insertSublayer:gradient atIndex:2];
}
@end

