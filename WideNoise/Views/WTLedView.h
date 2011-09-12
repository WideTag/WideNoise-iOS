//
//  WTLedView.h
//  WideNoise
//
//  Created by Emilio Pavia on 01/09/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WTLedView;

@protocol WTLedViewDataSource <NSObject>

- (CGFloat)ledView:(WTLedView *)ledView valueForColumnAtIndex:(NSUInteger)index;

@end

@interface WTLedView : UIView

@property (nonatomic, assign) IBOutlet id <WTLedViewDataSource> dataSource;
@property (nonatomic, retain) UIColor *ledColor;

@property (nonatomic, readonly) NSUInteger numberOfCols;
@property (nonatomic, readonly) NSUInteger numberOfRows;

@end
