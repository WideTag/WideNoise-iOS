//
//  ListenViewController.h
//  WideNoise
//
//  Created by Emilio Pavia on 24/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#import "WTLedView.h"
#import "WTNoiseRecorder.h"

@interface ListenViewController : UIViewController <CLLocationManagerDelegate, UIScrollViewDelegate, WTLedViewDataSource, WTNoiseRecorderDelegate>

@property (nonatomic, retain) IBOutlet UIImageView *bgView;
@property (nonatomic, retain) IBOutlet UIImageView *meterView;
@property (nonatomic, retain) IBOutlet UIImageView *pageView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) IBOutlet UIView *samplingView;
@property (nonatomic, retain) IBOutlet UIImageView *recordView;
@property (nonatomic, retain) IBOutlet UIImageView *locationView;
@property (nonatomic, retain) IBOutlet WTLedView *ledView;
@property (nonatomic, retain) IBOutlet UILabel *dbLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UIButton *takeButton;
@property (nonatomic, retain) IBOutlet UIButton *extendButton;
@property (nonatomic, retain) IBOutlet UIButton *qualifyButton;

@property (nonatomic, retain) IBOutlet UIView *qualifyView;

- (IBAction)action:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)setType:(id)sender;
- (IBAction)sendReport:(id)sender;

@end
