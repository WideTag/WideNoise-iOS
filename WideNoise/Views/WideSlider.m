//
//  WideSlider.m
//  WideNoise
//
//  Created by Emilio Pavia on 21/11/11.
//  Copyright (c) 2011 WideTag, Inc. All rights reserved.
//

#import "WideSlider.h"

#define SLIDER_X_BOUND 15
#define SLIDER_Y_BOUND 10

@implementation WideSlider

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value 
{
    CGRect result = [super thumbRectForBounds:bounds trackRect:rect value:value];
    _lastBounds = result;
    
    return result;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event 
{
    UIView* result = [super hitTest:point withEvent:event];
    if (result != self) {
        // check if this is within what we consider a reasonable range. It will for x as x is the whole slider
        if ((point.y >= -15) && (point.y < (_lastBounds.size.height + SLIDER_Y_BOUND))) {
            result = self;
        }
    }
    
    // NSLog(@"UISlider(%d).hitTest: (%f, %f) result=%d", self, point.x, point.y, result);
    
    return result;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event 
{
    BOOL result = [super pointInside:point withEvent:event];
    
    if (!result) {
        
        // check if this is within what we consider a reasonable range for just the ball
        if ((point.x >= (_lastBounds.origin.x - SLIDER_X_BOUND)) && (point.x <= (_lastBounds.origin.x + _lastBounds.size.width + SLIDER_X_BOUND))
            && (point.y >= -SLIDER_Y_BOUND) && (point.y < (_lastBounds.size.height + SLIDER_Y_BOUND))) {
            
            result = YES;
        }
    }
    
    // NSLog(@"UISlider(%d).pointInside: (%f, %f) result=%d", self, point.x, point.y, result);
    
    return result;
}


@end
