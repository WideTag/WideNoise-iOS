//
//  ListenViewController.h
//  WideNoise
//
//  Created by Emilio Pavia on 24/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WTNoiseRecorder.h"

@interface ListenViewController : UIViewController <WTNoiseRecorderDelegate>

@property (nonatomic, retain) IBOutlet UIButton *takeButton;
@property (nonatomic, retain) IBOutlet UIButton *extendButton;
@property (nonatomic, retain) IBOutlet UIButton *qualifyButton;

- (IBAction)takeNoiseSample:(id)sender;
- (IBAction)extendSampling:(id)sender;
- (IBAction)qualifyNoise:(id)sender;

@end
