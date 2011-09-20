//
//  WideNoiseAppDelegate.h
//  WideNoise
//
//  Created by Emilio Pavia on 23/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FBConnect.h"
#import "XAuthTwitterEngine.h"
#import "XAuthTwitterEngineDelegate.h"

extern NSString * const FacebookDidLoginNotification;
extern NSString * const FacebookDidLogoutNotification;
extern NSString * const TwitterDidSuccessNotification;
extern NSString * const TwitterDidFailNotification;
extern NSString * const TwitterDidFinishNotification;

@class XAuthTwitterEngine;

@interface WideNoiseAppDelegate : NSObject <FBSessionDelegate, UIApplicationDelegate, XAuthTwitterEngineDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) XAuthTwitterEngine *twitter;

@end
