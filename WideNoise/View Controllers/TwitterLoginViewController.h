//
//  TwitterLoginViewController.h
//  WideNoise
//
//  Created by Emilio Pavia on 19/09/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TwitterLoginViewController;

@protocol TwitterLoginDelegate <NSObject>

- (void)twitterLoginViewController:(TwitterLoginViewController *)twitterLoginViewController loginWithUsername:(NSString *)username password:(NSString *)password;

@end

@interface TwitterLoginViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, assign) id <TwitterLoginDelegate> delegate;

- (IBAction)cancel:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)showLoginError:(id)sender;

@end
