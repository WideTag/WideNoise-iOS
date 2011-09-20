//
//  WideNoiseAppDelegate.m
//  WideNoise
//
//  Created by Emilio Pavia on 23/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "WideNoiseAppDelegate.h"

#import "SFHFKeychainUtils.h"

NSString * const FacebookDidLoginNotification = @"FacebookDidLoginNotification";
NSString * const FacebookDidLogoutNotification = @"FacebookDidLogoutNotification";
NSString * const TwitterDidSuccessNotification = @"TwitterDidSuccessNotification";
NSString * const TwitterDidFailNotification = @"TwitterDidFailNotification";
NSString * const TwitterDidFinishNotification = @"TwitterDidFinishNotification";

@implementation WideNoiseAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

@synthesize facebook;
@synthesize twitter;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.facebook = [[[Facebook alloc] initWithAppId:FACEBOOK_APP_ID andDelegate:self] autorelease];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    self.twitter = [[[XAuthTwitterEngine alloc] initXAuthWithDelegate:self] autorelease];
    self.twitter.consumerKey = TWITTER_CONSUMER_KEY;
    self.twitter.consumerSecret = TWITTER_CONSUMER_SECRET;
    [self.twitter setUsername:[[NSUserDefaults standardUserDefaults] objectForKey:kTwitterUsernameDefaultKey] password:nil];
    
    [self.window addSubview:self.tabBarController.view];
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{
    return [self.facebook handleOpenURL:url]; 
}

- (void)fbDidLogin 
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FacebookDidLoginNotification object:self];
}

- (void)fbDidLogout
{
    [[NSNotificationCenter defaultCenter] postNotificationName:FacebookDidLogoutNotification object:self];
}

- (void)storeCachedTwitterXAuthAccessTokenString:(NSString *)tokenString forUsername:(NSString *)username
{
	[SFHFKeychainUtils storeUsername:username andPassword:tokenString forServiceName:@"twitter.token" updateExisting:YES error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TwitterDidSuccessNotification object:self userInfo:[NSDictionary dictionaryWithObject:username forKey:@"username"]];
}

- (NSString *)cachedTwitterXAuthAccessTokenStringForUsername:(NSString *)username
{
    return [SFHFKeychainUtils getPasswordForUsername:username andServiceName:@"twitter.token" error:nil];;
}

- (void) twitterXAuthConnectionDidFailWithError: (NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TwitterDidFailNotification object:self];
}

- (void)connectionFinished:(NSString *)identifier
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TwitterDidFinishNotification object:self];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [facebook release];
    [twitter release];
    [super dealloc];
}

@end
