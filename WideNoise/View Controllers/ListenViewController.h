//
//  ListenViewController.h
//  WideNoise
//
//  Created by Emilio Pavia on 24/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#import "TagsViewController.h"
#import "WTLedView.h"
#import "WTNoiseRecorder.h"

@class WTNoise;

@interface ListenViewController : UIViewController <CLLocationManagerDelegate, TagsViewControllerDelegate, UIAlertViewDelegate, UIScrollViewDelegate, WTLedViewDataSource, WTNoiseRecorderDelegate>

@property (nonatomic, retain) IBOutlet UIImageView *bgView;
@property (nonatomic, retain) IBOutlet UIImageView *meterView;
@property (nonatomic, retain) IBOutlet UIImageView *pageView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *samplingView;
@property (nonatomic, retain) IBOutlet UIScrollView *samplingScrollView;
@property (nonatomic, retain) IBOutlet UIView *samplingSubview1;
@property (nonatomic, retain) IBOutlet UIView *samplingSubview2;
@property (nonatomic, retain) IBOutlet UIView *samplingSubview3;
@property (nonatomic, retain) IBOutlet UIImageView *stopView;
@property (nonatomic, retain) IBOutlet UIImageView *recordView;
@property (nonatomic, retain) IBOutlet UIImageView *locationView;
@property (nonatomic, retain) IBOutlet WTLedView *ledView;
@property (nonatomic, retain) IBOutlet UILabel *dbLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *predictedDbLabel;
@property (nonatomic, retain) IBOutlet UILabel *predictedDescriptionLabel;
@property (nonatomic, retain) IBOutlet UIImageView *matchImageView;
@property (nonatomic, retain) IBOutlet UIButton *takeButton;
@property (nonatomic, retain) IBOutlet UIButton *extendButton;
@property (nonatomic, retain) IBOutlet UIImageView *sliderLedView;
@property (nonatomic, retain) IBOutlet UISlider *slider;
@property (nonatomic, retain) IBOutlet UIButton *restartButton;
@property (nonatomic, retain) IBOutlet UIButton *qualifyButton;
@property (nonatomic, retain) IBOutlet UIButton *sendButton;
@property (nonatomic, retain) IBOutlet UIButton *tagButton;
@property (nonatomic, retain) IBOutlet UIButton *shareButton;
@property (nonatomic, retain) IBOutlet UIButton *newButton;
@property (nonatomic, retain) IBOutlet UIView *qualifyView;
@property (nonatomic, retain) IBOutlet UIView *sendingView;
@property (nonatomic, retain) IBOutlet UIImageView *statusView;

@property (nonatomic, retain) WTNoise *recordedNoise;

- (IBAction)action:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)setType:(id)sender;
- (IBAction)sendReport:(id)sender;
- (IBAction)selectTags:(id)sender;
- (IBAction)shareResult:(id)sender;
- (IBAction)changePrediction:(id)sender;

@end
