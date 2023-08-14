//
//  CustomSlider.m
//  PlutoController
//
//  Created by Drona Aviation on 14/05/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "CustomSlider.h"

@implementation CustomSlider

- (CGRect)trackRectForBounds:(CGRect)bounds {
    CGRect frame = CGRectMake(0, 0, self.bounds.size.width, 6);
    frame.origin.y = (self.bounds.size.height * 0.5) - 3;
    CGRect rect = frame;
    return rect;
}

-(void) setGradient {
    CAGradientLayer *gradient = [CAGradientLayer layer];
        
    CGRect frame = CGRectMake(0, 0, 200, 6);
    frame.origin.y = (self.bounds.size.height * 0.5) - 3;
    gradient.frame = frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    gradient.cornerRadius = 3;
    gradient.startPoint = CGPointMake(0, 0.6);
    gradient.endPoint = CGPointMake(1, 0.4);
    [self.layer insertSublayer:gradient atIndex:0];

}
@end
