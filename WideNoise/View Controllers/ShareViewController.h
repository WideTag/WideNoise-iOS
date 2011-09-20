//
//  ShareViewController.h
//  WideNoise
//
//  Created by Emilio Pavia on 24/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TwitterLoginViewController.h"

@interface ShareViewController : UIViewController <TwitterLoginDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) IBOutlet UIButton *twitterButton;
@property (nonatomic, retain) IBOutlet UIButton *facebookButton;
@property (nonatomic, retain) IBOutlet UIButton *emailButton;

- (IBAction)linkTwitter:(id)sender;
- (IBAction)linkFacebook:(id)sender;
- (IBAction)sendEmail:(id)sender;

@end
