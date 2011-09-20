//
//  WTLedView.m
//  WideNoise
//
//  Created by Emilio Pavia on 01/09/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "WTLedView.h"

#define PIXEL_WIDTH 2
#define PIXEL_PITCH 1
#define COL_WIDTH (PIXEL_WIDTH + PIXEL_PITCH)

@implementation WTLedView

@synthesize ledColor = _ledColor;
@synthesize dataSource = _dataSource;

#pragma mark - Properties

- (NSUInteger)numberOfCols
{
    return (NSUInteger)(self.frame.size.width / COL_WIDTH);
}

- (NSUInteger)numberOfRows
{
    return (NSUInteger)(self.frame.size.height / COL_WIDTH);
}

#pragma mark -

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.ledColor = [UIColor redColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, self.ledColor.CGColor);
    CGFloat dashArray[] = {PIXEL_WIDTH, PIXEL_PITCH};
    CGContextSetLineDash(context, 0, dashArray, 2);
    
    NSUInteger cols = self.numberOfCols;
    NSUInteger rows = self.numberOfRows;
    for (int i=1; i<=cols; i++) {
        CGFloat value = [self.dataSource ledView:self valueForColumnAtIndex:i-1];
        if (value <= 0.0) {
            continue;
        } else if (value > 1.0) {
            value = 1.0;
        }
        
        CGContextMoveToPoint(context, COL_WIDTH*i, self.frame.size.height);
        CGContextAddLineToPoint(context, COL_WIDTH*i, self.frame.size.height - ((int)(rows*value) * COL_WIDTH));
        
        CGContextStrokePath(context);             
    }
}

- (void)dealloc
{
    [_ledColor release];
    [super dealloc];
}

@end
