//
//  ListenViewController.m
//  WideNoise
//
//  Created by Emilio Pavia on 24/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "ListenViewController.h"

#import <AudioToolbox/AudioServices.h>

#import "Facebook.h"
#import "NSURLConnection+Blocks.h"
#import "WideNoiseAppDelegate.h"
#import "WTRequestFactory.h"

#define SOCIAL_MESSAGE @"just read %.1fdb of %@ with #WideNoise"
#define SOCIAL_URL @"http://widenoise.com/%@"

#define SAMPLES_PER_SECOND 20
#define RECORD_DURATION 5 // in seconds
#define MAX_RECORDS 3
#define SWIPE_ANIMATION_DURATION 0.4f // in seconds

#define kSendingErrorAlertViewTag 1
#define kWideNoiseLogoTag 2

@interface ListenViewController ()

@property (nonatomic, retain) WTNoiseRecorder *noiseRecorder;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) NSTimer *samplingTimer;

@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) NSMutableSet *types;

@property (nonatomic, assign) BOOL shared;

- (void)scrollToPage:(NSUInteger)page;
- (void)updateLocation;

- (void)shareToSocialNetworks;
- (void)handleConnectionError;
- (void)completeSendingReport;

@end

@implementation ListenViewController

@synthesize bgView = _bgView;
@synthesize meterView;
@synthesize pageView = _pageView;
@synthesize scrollView = _scrollView;
@synthesize samplingView = _samplingView;
@synthesize samplingScrollView = _samplingScrollView;
@synthesize samplingSubview1;
@synthesize samplingSubview2;
@synthesize samplingSubview3;
@synthesize stopView;
@synthesize recordView;
@synthesize locationView;
@synthesize ledView = _ledView;
@synthesize dbLabel;
@synthesize descriptionLabel;
@synthesize predictedDbLabel;
@synthesize predictedDescriptionLabel;
@synthesize guessTextView;
@synthesize matchImageView;
@synthesize takeButton;
@synthesize extendButton;
@synthesize sliderLedView;
@synthesize slider;
@synthesize restartButton;
@synthesize qualifyButton;
@synthesize sendButton;
@synthesize tagButton;
@synthesize shareButton;
@synthesize newButton;
@synthesize qualifyView;
@synthesize sendingView;
@synthesize statusView;

@synthesize recordedNoise = _recordedNoise;

@synthesize noiseRecorder = _noiseRecorder;
@synthesize locationManager = _locationManager;
@synthesize samplingTimer;

@synthesize currentLocation;
@synthesize types;

@synthesize shared;

#pragma mark - IBAction methods

- (IBAction)action:(id)sender
{
    if (sender == self.takeButton) {
        self.takeButton.enabled = NO;
        self.extendButton.enabled = NO;
        self.sliderLedView.highlighted = YES;
        self.guessTextView.hidden = NO;
        self.slider.enabled = YES;
        self.slider.selected = NO;
        self.pageView.image = [UIImage imageNamed:@"pager_2.png"];
        
        UIView *logo = [[self.view viewWithTag:kWideNoiseLogoTag] retain];
        if (logo.superview != self.samplingSubview1) {
            [logo removeFromSuperview];
            [self.samplingSubview1 addSubview:logo];
        }
        [logo release];
        
        [UIView animateWithDuration:SWIPE_ANIMATION_DURATION 
                         animations:^{
                             [self.samplingScrollView scrollRectToVisible:CGRectMake(self.samplingScrollView.frame.size.width,
                                                                                     0, 
                                                                                     self.samplingScrollView.frame.size.width, 
                                                                                     self.samplingScrollView.frame.size.height) 
                                                                 animated:NO];
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 self.stopView.hidden = YES;
                                 self.recordView.hidden = NO;
                                 
                                 [self updateLocation];
                                 [self.noiseRecorder recordForDuration:RECORD_DURATION];
                                 [self.ledView setNeedsDisplay];
                             }                             
                         }];
        
    } else if (sender == self.extendButton) {
        self.extendButton.enabled = NO;
        
        [self.noiseRecorder recordForDuration:RECORD_DURATION];
        [self.ledView setNeedsDisplay];
    } else if (sender == self.qualifyButton) {
        self.qualifyButton.enabled = NO;
        
        [self scrollToPage:1];
    }
}

- (IBAction)clear:(id)sender
{
    self.noiseRecorder = [[[WTNoiseRecorder alloc] init] autorelease];
    self.noiseRecorder.delegate = self;
    self.noiseRecorder.samplesPerSecond = SAMPLES_PER_SECOND;
    
    self.currentLocation = nil;
    
    self.meterView.image = [UIImage imageNamed:@"noise_meter_off.png"];
    self.dbLabel.text = @"";
    self.descriptionLabel.text = @"";
    self.predictedDbLabel.text = @"";
    self.predictedDescriptionLabel.text = @"";
    self.matchImageView.hidden = YES;
    self.guessTextView.hidden = YES;
    self.slider.value = 0.0f;
    self.slider.enabled = NO;
    self.slider.selected = NO;
    self.locationView.hidden = YES;
    self.stopView.hidden = NO;
    self.recordView.hidden = YES;
    self.statusView.image = [UIImage imageNamed:@"status_screen.png"];
    
    self.types = [NSMutableSet set];
    
    self.shared = NO;
    
    for (UIView *subview in self.qualifyView.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            [(UIButton *)subview setSelected:NO];
        }
    }
    
    self.takeButton.enabled = YES;
    self.takeButton.selected = NO;
    self.extendButton.enabled = NO;
    self.restartButton.enabled = NO;
    self.qualifyButton.enabled = NO;
    
    self.sendButton.enabled = NO;
    
    self.tagButton.enabled = NO;
    self.shareButton.enabled = NO;
    self.newButton.enabled = NO;
    
    [self.ledView setNeedsDisplay];
    
    if (sender == self.restartButton) {
        self.pageView.image = [UIImage imageNamed:@"pager_1.png"];
        [UIView animateWithDuration:SWIPE_ANIMATION_DURATION 
                         animations:^{
                             [self.samplingScrollView scrollRectToVisible:CGRectMake(0,
                                                                                     0, 
                                                                                     self.samplingScrollView.frame.size.width, 
                                                                                     self.samplingScrollView.frame.size.height) 
                                                                 animated:NO];
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 
                             }                             
                         }];
    } else {
        [self.samplingScrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        [self scrollToPage:0];
    }
}

- (IBAction)setType:(id)sender
{
    UIButton *typeButton = (UIButton *)sender;
    NSString *type = nil;
    switch (typeButton.tag) {
        case 10:
            type = @"natural";
            break;
        case 11:
            type = @"artificial";
            break;
        case 12:
            type = @"lovable";
            break;
        case 13:
            type = @"hurting";
            break;
        case 14:
            type = @"indoor";
            break;
        case 15:
            type = @"outdoor";
            break;
        case 16:
            type = @"single";
            break;
        case 17:
            type = @"multiple";
            break;
        default:
            break;
    }
    
    if ([typeButton isSelected]) {
        [typeButton setSelected:NO];
        [self.types removeObject:type];
    } else {
        [typeButton setBackgroundImage:[typeButton backgroundImageForState:UIControlStateHighlighted] forState:(UIControlStateSelected | UIControlStateHighlighted)];
        [typeButton setSelected:YES];
        [self.types addObject:type];
    }
    
    if ([self.types count] > 0) {
        self.sendButton.enabled = YES;
    } else {
        self.sendButton.enabled = NO;
    }
}

- (IBAction)sendReport:(id)sender
{
    self.sendButton.enabled = NO;
    self.tagButton.enabled = NO;
    self.shareButton.enabled = NO;
    self.newButton.enabled = NO;
    
    [self scrollToPage:2];
    [[self statusView] setImage:[UIImage imageNamed:@"status_screen_sending.png"]];
    
    self.recordedNoise.location = self.currentLocation;
    
    self.recordedNoise.types = [[self.types allObjects] sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSURLRequest *request = [[WTRequestFactory factory] requestForReportingNoise:self.recordedNoise date:[NSDate date]];
    __block typeof(self) selfRef = self;
    __block WTNoise *blockNoise = self.recordedNoise;
    [NSURLConnection sendAsynchronousRequest:request
                                   onSuccess:^(NSData *data, NSURLResponse *response) {
                                       NSString *responseString = [[NSString alloc] initWithBytes:[data bytes]
                                                                                           length:[data length] 
                                                                                         encoding:NSUTF8StringEncoding];
                                       NSDictionary *responseJSON = [responseString JSONValue];
                                       if ([responseJSON objectForKey:@"status"] != nil && [[responseJSON objectForKey:@"status"] intValue] == 0) {
                                           blockNoise.identifier = [responseJSON objectForKey:@"id"];
                                           [selfRef completeSendingReport];
                                       } else {
                                           NSLog(@"An error occurred when trying to report noise (status = %@)", [responseJSON objectForKey:@"status"]);
                                           [selfRef handleConnectionError];
                                       }
                                   } 
                                   onFailure:^(NSData *data, NSError *error) {                                       
                                       [selfRef handleConnectionError];
                                   }];
}

- (IBAction)selectTags:(id)sender
{
    self.tagButton.enabled = NO;
    
    TagsViewController *tagsController = [[TagsViewController alloc] initWithNibName:@"TagsViewController" bundle:nil];
    tagsController.selectedTags = [NSSet setWithArray:self.recordedNoise.tags];
    tagsController.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tagsController];
    [self presentModalViewController:navController animated:YES];
    [navController release];
    [tagsController release];
}

- (IBAction)shareResult:(id)sender
{
    self.shareButton.enabled = NO;
    self.shared = YES;
    [self shareToSocialNetworks];
}

- (IBAction)changePrediction:(id)sender
{
    if (![(UISlider *)sender isEnabled]) {
        return;
    }
    
    self.guessTextView.hidden = YES;
    [(UISlider *)sender setSelected:YES];
    float db = [(UISlider *)sender value];
    NSString *description = nil;
    if (db <= 30) {
        description = @"Feather";
	} else if (db <= 60) {
        description = @"Sleeping Cat";
	} else if (db <= 70) {
        description = @"TV";
	} else if (db <= 90) {
        description = @"Car";
	} else if (db <= 100) {
        description = @"Dragster";
	} else if (db <= 115) {
        description = @"T-rex";
	} else {
        description = @"Rock Concert";
	}
    
    self.predictedDbLabel.text = [NSString stringWithFormat:@"%.0fdb", db];
    self.predictedDescriptionLabel.text = description;
}

#pragma mark - Private methods

- (void)scrollToPage:(NSUInteger)page
{
    int dot = page+1;
    if (page > 0) {
        dot += 2;
    }
    NSString *imageName = [NSString stringWithFormat:@"pager_%d.png", dot];
    self.pageView.image = [UIImage imageNamed:imageName];
    
    [UIView animateWithDuration:SWIPE_ANIMATION_DURATION 
                     animations:^{
                         [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.frame.size.width * (page+1), 
                                                                         0, 
                                                                         self.scrollView.frame.size.width, 
                                                                         self.scrollView.frame.size.height) 
                                                     animated:NO];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                         }                             
                     }];
}

- (void)updateLocation
{
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services" 
                                                            message:@"You must enable location services in your device settings in order to use this application." 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    } else {
        self.locationView.hidden = NO;
        
        [self.locationManager startUpdatingLocation];
    }
}

- (void)shareToSocialNetworks
{    
    NSString *link = [NSString stringWithFormat:SOCIAL_URL, self.recordedNoise.identifier];
    NSString *description = [NSString stringWithFormat:SOCIAL_MESSAGE, self.recordedNoise.averageLevel, self.recordedNoise];
    
    Facebook *facebook = ((WideNoiseAppDelegate *)[[UIApplication sharedApplication] delegate]).facebook;
    XAuthTwitterEngine *twitter = ((WideNoiseAppDelegate *)[[UIApplication sharedApplication] delegate]).twitter;
    
    BOOL hasFacebook = [facebook isSessionValid];
    BOOL hasTwitter = [twitter isAuthorized];
    
    if (hasFacebook) {
        [facebook requestWithGraphPath:@"me/feed" 
                             andParams:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:link, description, nil]
                                                                                                forKeys:[NSArray arrayWithObjects:@"link", @"description", nil]]
                         andHttpMethod:@"POST"
                           andDelegate:nil];
    }
    if (hasTwitter) {
        [twitter sendUpdate:[NSString stringWithFormat:@"%@ %@", description, link]];
    }
}

- (void)handleConnectionError
{
    [[self statusView] setImage:[UIImage imageNamed:@"status_screen.png"]];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ConnectionErrorAlertTitle", @"") 
                                                    message:NSLocalizedString(@"ConnectionErrorAlertMessage", @"") 
                                                   delegate:self 
                                          cancelButtonTitle:NSLocalizedString(@"AlertViewNo", @"") 
                                          otherButtonTitles:NSLocalizedString(@"AlertViewYes", @""), nil];
    [alert setTag:kSendingErrorAlertViewTag];
    [alert show];
    [alert release];
}

- (void)completeSendingReport
{
    self.tagButton.enabled = YES;
    
    Facebook *facebook = ((WideNoiseAppDelegate *)[[UIApplication sharedApplication] delegate]).facebook;
    XAuthTwitterEngine *twitter = ((WideNoiseAppDelegate *)[[UIApplication sharedApplication] delegate]).twitter;
    
    BOOL hasFacebook = [facebook isSessionValid];
    BOOL hasTwitter = [twitter isAuthorized];
    if (hasTwitter || hasFacebook) {
        self.shareButton.enabled = YES;
    } else {
        self.shareButton.enabled = NO;
    }
    
    self.newButton.enabled = YES;

    self.statusView.image = [UIImage imageNamed:@"status_screen_done.png"];
}

#pragma mark - CoreLocation delegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (newLocation.horizontalAccuracy >= 0 && newLocation.horizontalAccuracy < 100) {
        self.currentLocation = newLocation;
        [manager stopUpdatingLocation];
        
        self.locationView.hidden = YES;
    }    
}

#pragma mark - WTLedViewDataSource methods

- (CGFloat)ledView:(WTLedView *)ledView valueForColumnAtIndex:(NSUInteger)index
{
    WTNoise *noise = self.noiseRecorder.recordedNoise;

    NSUInteger totalSamples = self.noiseRecorder.samplesPerSecond * self.noiseRecorder.recordingDuration;
    float len = totalSamples / (float)ledView.numberOfCols;
    float level = 0.0;
    
    NSUInteger j = (int)(len*index);
    if (j < [noise.samples count]) {
        level = [(NSNumber *)[noise.samples objectAtIndex:j] floatValue];
    } else {
        level = 0;
    }
    
    CGFloat value = 0.0;
    if (level <= 0) {
        value = 0.0;
    } else if (level <= 30) {
        value = 0.07;
    } else if (level <= 100) {
        value = 0.07 + ((level-30.0)/70.0)*0.97;
    } else {
        value = 1.0;
    }
    return value;
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kSendingErrorAlertViewTag) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            [self clear:nil];
        } else {
            self.sendButton.enabled = YES;
            
            [self scrollToPage:1];
        }        
    }
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSUInteger page = floorf(CGRectGetMinX(scrollView.bounds) / CGRectGetWidth(scrollView.bounds)) + 1;
    NSString *imageName = [NSString stringWithFormat:@"pager_%d.png", page];
    self.pageView.image = [UIImage imageNamed:imageName];
}

#pragma mark - WTNoiseRecorderDelegate methods

- (void)noiseRecorder:(WTNoiseRecorder *)noiseRecorder didUpdateNoise:(WTNoise *)noise
{        
    NSUInteger totalSamples = noiseRecorder.recordingDuration*noiseRecorder.samplesPerSecond;
    if ((noise.samples.count > totalSamples/2) && (totalSamples < SAMPLES_PER_SECOND*RECORD_DURATION*MAX_RECORDS)) {
        self.extendButton.enabled = YES;
    }
    
    [self.ledView setNeedsDisplay];
}

- (void)noiseRecorderDidFinishRecording:(WTNoiseRecorder *)noiseRecorder
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    self.recordedNoise = noiseRecorder.recordedNoise;
    
    self.guessTextView.hidden = YES;
    self.stopView.hidden = NO;
    self.recordView.hidden = YES;
    self.slider.enabled = NO;
    self.slider.selected = NO;
    
    float db = self.recordedNoise.averageLevel;
    NSString *imageName = nil;
    NSString *description = nil;
    if (db <= 30) {
		imageName = @"noise_meter_1.png";
        description = @"Feather";
	} else if (db <= 60) {
		imageName = @"noise_meter_2.png";
        description = @"Sleeping Cat";
	} else if (db <= 70) {
		imageName = @"noise_meter_3.png";
        description = @"TV";
	} else if (db <= 90) {
		imageName = @"noise_meter_4.png";
        description = @"Car";
	} else if (db <= 100) {
		imageName = @"noise_meter_5.png";
        description = @"Dragster";
	} else if (db <= 115) {
		imageName = @"noise_meter_6.png";
        description = @"T-rex";
	} else {
		imageName = @"noise_meter_7.png";
        description = @"Rock Concert";
	}
    
    [self changePrediction:self.slider];
    
    self.meterView.image = [UIImage imageNamed:imageName];
    self.dbLabel.text = [NSString stringWithFormat:@"%ddb", (int)self.recordedNoise.averageLevel];
    self.descriptionLabel.text = description;
    
    if (db == self.slider.value) {
        [self.matchImageView setImage:[UIImage imageNamed:@"perfect.png"]];
    } else if (abs(db-self.slider.value) <= 5) {
        [self.matchImageView setImage:[UIImage imageNamed:@"good.png"]];
    } else {
        [self.matchImageView setImage:[UIImage imageNamed:@"no_match.png"]];
    }
    self.matchImageView.hidden = NO;
    
    self.extendButton.enabled = NO;
    self.sliderLedView.highlighted = NO;
    self.restartButton.enabled = YES;
    self.qualifyButton.enabled = YES;
    self.pageView.image = [UIImage imageNamed:@"pager_3.png"];
    
    [UIView animateWithDuration:SWIPE_ANIMATION_DURATION 
                     animations:^{
                         [self.samplingScrollView scrollRectToVisible:CGRectMake(self.samplingScrollView.frame.size.width*2,
                                                                                 0, 
                                                                                 self.samplingScrollView.frame.size.width, 
                                                                                 self.samplingScrollView.frame.size.height) 
                                                             animated:NO];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                         }                             
                     }];
}

#pragma mark - TagsViewControllerDelegate methods

- (void)tagsViewController:(TagsViewController *)tagsViewController didSelectTags:(NSSet *)tags
{
    self.recordedNoise.tags = [[tagsViewController.selectedTags allObjects] sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    [[self statusView] setImage:[UIImage imageNamed:@"status_screen_sending.png"]];
    
    //UIButton *blockTagButton = self.tagButton;
    UIImageView *blockStatusView = self.statusView;
    NSURLRequest *request = [[WTRequestFactory factory] requestForAssigningTags:self.recordedNoise.tags toNoise:self.recordedNoise];
    [NSURLConnection sendAsynchronousRequest:request
                                   onSuccess:^(NSData *data, NSURLResponse *response) {
                                       //blockTagButton.enabled = YES;
                                       [blockStatusView setImage:[UIImage imageNamed:@"status_screen_done.png"]];
                                   } 
                                   onFailure:^(NSData *data, NSError *error) {   
                                       //blockTagButton.enabled = YES;
                                       [blockStatusView setImage:[UIImage imageNamed:@"status_screen.png"]];
                                   }];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)tagsViewControllerDidCancel:(TagsViewController *)tagsViewController
{
    self.tagButton.enabled = YES;
    
    [self dismissModalViewControllerAnimated:YES];
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
    [_bgView release];
    [_pageView release];
    [_scrollView release];
    [_samplingView release];
    [_samplingScrollView release];
    [samplingSubview1 release];
    [samplingSubview2 release];
    [samplingSubview3 release];
    [stopView release];
    [recordView release];
    [locationView release];
    [meterView release];
    [_ledView release];
    [dbLabel release];
    [descriptionLabel release];
    [predictedDbLabel release];
    [predictedDescriptionLabel release];
    [guessTextView release];
    [matchImageView release];
    [takeButton release];
    [extendButton release];
    [sliderLedView release];
    [slider release];
    [restartButton release];
    [qualifyButton release];
    [sendButton release];
    [tagButton release];
    [shareButton release];
    [newButton release];
    [qualifyView release];
    [sendingView release];
    [statusView release];
    
    [_recordedNoise release];
    
    [_noiseRecorder release];
    [_locationManager release];
    
    [currentLocation release];
    [types release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 4, self.scrollView.frame.size.height);
    self.samplingView.frame = CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.qualifyView.frame = CGRectMake(self.scrollView.frame.size.width*2, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.sendingView.frame = CGRectMake(self.scrollView.frame.size.width*3, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [self.scrollView addSubview:self.samplingView];
    [self.scrollView addSubview:self.qualifyView];
    [self.scrollView addSubview:self.sendingView];
    
    self.samplingScrollView.contentSize = CGSizeMake(self.samplingScrollView.frame.size.width * 3, self.samplingScrollView.frame.size.height);
    self.samplingSubview1.frame = CGRectMake(0, 0, self.samplingScrollView.frame.size.width, self.samplingScrollView.frame.size.height);
    self.samplingSubview2.frame = CGRectMake(self.samplingScrollView.frame.size.width, 0, self.samplingScrollView.frame.size.width, self.samplingScrollView.frame.size.height);
    self.samplingSubview3.frame = CGRectMake(self.samplingScrollView.frame.size.width*2, 0, self.samplingScrollView.frame.size.width, self.samplingScrollView.frame.size.height);
    [self.samplingScrollView addSubview:self.samplingSubview1];
    [self.samplingScrollView addSubview:self.samplingSubview2];
    [self.samplingScrollView addSubview:self.samplingSubview3];
    
    [self scrollToPage:0];
    
    self.ledView.ledColor = [UIColor colorWithRed:1.0 green:172.0/255.0 blue:83.0/255.0 alpha:1.0];
    
    // UIColor *ledColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pixel_pattern.png"]];
    // self.dbLabel.textColor = ledColor;
    // self.descriptionLabel.textColor = ledColor;
    
    [self.takeButton setBackgroundImage:[self.takeButton backgroundImageForState:UIControlStateHighlighted] forState:(UIControlStateSelected | UIControlStateHighlighted)];

    [self.slider setThumbImage:[UIImage imageNamed:@"thumb_on.png"] forState:UIControlStateNormal];
    [self.slider setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateDisabled];
    [self.slider setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateDisabled|UIControlStateSelected];
    [self.slider setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateDisabled|UIControlStateHighlighted];
    [self.slider setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateSelected];
    [self.slider setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateSelected|UIControlStateHighlighted];
    [self.slider setMinimumTrackImage:[[UIImage imageNamed:@"left_bar.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] forState:UIControlStateNormal];
    [self.slider setMaximumTrackImage:[[UIImage imageNamed:@"right_bar.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] forState:UIControlStateNormal];
    [self.slider setMinimumTrackImage:[[UIImage imageNamed:@"left_bar.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] forState:UIControlStateDisabled];
    [self.slider setMaximumTrackImage:[[UIImage imageNamed:@"right_bar.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] forState:UIControlStateDisabled];
    
    [self clear:nil];
    
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.bgView = nil;
    self.pageView = nil;
    self.scrollView = nil;
    self.samplingView = nil;
    self.samplingScrollView = nil;
    self.samplingSubview1 = nil;
    self.samplingSubview2 = nil;
    self.samplingSubview3 = nil;
    self.stopView = nil;
    self.recordView = nil;
    self.locationView = nil;
    self.meterView = nil;
    self.ledView = nil;
    self.dbLabel = nil;
    self.descriptionLabel = nil;
    self.predictedDbLabel = nil;
    self.predictedDescriptionLabel = nil;
    self.guessTextView = nil;
    self.matchImageView = nil;
    self.takeButton = nil;
    self.extendButton = nil;
    self.sliderLedView = nil;
    self.slider = nil;
    self.restartButton = nil;
    self.qualifyButton = nil;
    self.sendButton = nil;
    self.tagButton = nil;
    self.shareButton = nil;
    self.newButton = nil;
    self.qualifyView = nil;
    self.sendingView = nil;
    self.statusView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.locationManager stopUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.shared) {
        Facebook *facebook = ((WideNoiseAppDelegate *)[[UIApplication sharedApplication] delegate]).facebook;
        XAuthTwitterEngine *twitter = ((WideNoiseAppDelegate *)[[UIApplication sharedApplication] delegate]).twitter;
        
        BOOL hasFacebook = [facebook isSessionValid];
        BOOL hasTwitter = [twitter isAuthorized];
        if (hasTwitter || hasFacebook) {
            self.shareButton.enabled = YES;
        } else {
            self.shareButton.enabled = NO;
        }
    }
}

@end
