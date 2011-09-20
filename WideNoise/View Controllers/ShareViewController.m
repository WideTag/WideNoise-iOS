//
//  ShareViewController.m
//  WideNoise
//
//  Created by Emilio Pavia on 24/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "ShareViewController.h"

#import "WideNoiseAppDelegate.h"

#define kTwitterTag 100
#define kFacebookTag 200

@interface ShareViewController ()

@property (nonatomic, retain) TwitterLoginViewController *twitterViewController;

- (void)refreshUI;

- (void)handleFacebookNotification:(NSNotification *)notification;
- (void)handleTwitterNotification:(NSNotification *)notification;

@end

@implementation ShareViewController

@synthesize twitterButton;
@synthesize facebookButton;
@synthesize emailButton;

@synthesize twitterViewController;

#pragma mark IBAction methods

- (IBAction)linkTwitter:(id)sender
{
    if ([((WideNoiseAppDelegate *)[[UIApplication sharedApplication] delegate]).twitter isAuthorized]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TwitterLinkAlertTitle", @"") 
                                                            message:NSLocalizedString(@"TwitterLinkAlertMessage", @"")
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"AlertViewNo", @"") 
                                                  otherButtonTitles:NSLocalizedString(@"AlertViewYes", @""), nil];
        alertView.tag = kTwitterTag;
        [alertView show];
        [alertView release];
    } else {
        self.twitterViewController = [[[TwitterLoginViewController alloc] initWithNibName:@"TwitterLoginViewController" bundle:nil] autorelease];
        self.twitterViewController.delegate = self;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.twitterViewController];
        [self presentModalViewController:navController animated:YES];
        [navController release];
    }
}

- (IBAction)linkFacebook:(id)sender
{
    if ([((WideNoiseAppDelegate *)[[UIApplication sharedApplication] delegate]).facebook isSessionValid]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FacebookLinkAlertTitle", @"") 
                                                            message:NSLocalizedString(@"FacebookLinkAlertMessage", @"")
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"AlertViewNo", @"") 
                                                  otherButtonTitles:NSLocalizedString(@"AlertViewYes", @""), nil];
        alertView.tag = kFacebookTag;
        [alertView show];
        [alertView release];
    } else {
        [((WideNoiseAppDelegate *)[[UIApplication sharedApplication] delegate]).facebook authorize:[NSArray arrayWithObject:@"publish_stream"]];
    }
}

- (IBAction)sendEmail:(id)sender
{
    
}

#pragma mark - Private methods

- (void)refreshUI
{
    if ([((WideNoiseAppDelegate *)[[UIApplication sharedApplication] delegate]).twitter isAuthorized]) {
        self.twitterButton.selected = YES;
    } else {
        self.twitterButton.selected = NO;
    }
    
    if ([((WideNoiseAppDelegate *)[[UIApplication sharedApplication] delegate]).facebook isSessionValid]) {
        self.facebookButton.selected = YES;
    } else {
        self.facebookButton.selected = NO;
    }
}

- (void)handleFacebookNotification:(NSNotification *)notification
{
    [self refreshUI];
}

- (void)handleTwitterNotification:(NSNotification *)notification
{
    if (notification.name == TwitterDidSuccessNotification) {
        NSString *username = [notification.userInfo objectForKey:@"username"];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:username forKey:kTwitterUsernameDefaultKey];
        [userDefaults synchronize];
        
        [self dismissModalViewControllerAnimated:YES];
        [self refreshUI];
        
        self.twitterViewController = nil;
    } else if (notification.name == TwitterDidFailNotification) {
        [self.twitterViewController showLoginError:nil];
    }
}

#pragma mark - Twitter login delegate

- (void)twitterLoginViewController:(TwitterLoginViewController *)twitterLoginViewController loginWithUsername:(NSString *)username password:(NSString *)password
{
    XAuthTwitterEngine *twitter = ((WideNoiseAppDelegate *)[[UIApplication sharedApplication] delegate]).twitter;
    [twitter exchangeAccessTokenForUsername:username password:password];
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == kTwitterTag) {
            [((WideNoiseAppDelegate *)[[UIApplication sharedApplication] delegate]).twitter clearAccessToken];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:kTwitterUsernameDefaultKey];
            [userDefaults synchronize];
        } else if (alertView.tag == kFacebookTag) {
            [((WideNoiseAppDelegate *)[[UIApplication sharedApplication] delegate]).facebook 
             logout:(WideNoiseAppDelegate *)[[UIApplication sharedApplication] delegate]];
        }
    }
    
    [self refreshUI];
}

#pragma mark -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [twitterButton release];
    [facebookButton release];
    [emailButton release];
    [twitterViewController release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    id <UIApplicationDelegate> applicationDelegate = [[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFacebookNotification:) name:FacebookDidLoginNotification object:applicationDelegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFacebookNotification:) name:FacebookDidLogoutNotification object:applicationDelegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTwitterNotification:) name:TwitterDidSuccessNotification object:applicationDelegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTwitterNotification:) name:TwitterDidFailNotification object:applicationDelegate];
    
    [self.twitterButton setBackgroundImage:[self.twitterButton backgroundImageForState:UIControlStateSelected] forState:(UIControlStateSelected | UIControlStateHighlighted)];
    [self.facebookButton setBackgroundImage:[self.facebookButton backgroundImageForState:UIControlStateSelected] forState:(UIControlStateSelected | UIControlStateHighlighted)];
    [self.emailButton setBackgroundImage:[self.emailButton backgroundImageForState:UIControlStateSelected] forState:(UIControlStateSelected | UIControlStateHighlighted)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshUI];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.twitterButton = nil;
    self.facebookButton = nil;
    self.emailButton = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
