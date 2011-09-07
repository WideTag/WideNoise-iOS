//
//  ListenViewController.m
//  WideNoise
//
//  Created by Emilio Pavia on 24/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "ListenViewController.h"

#import <AudioToolbox/AudioServices.h>

#import "WTRequestFactory.h"

@interface ListenViewController ()

@property (nonatomic, retain) WTNoiseRecorder *noiseRecorder;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) NSTimer *samplingTimer;

@property (nonatomic, retain) CLLocation *currentLocation;

- (void)scrollToPage:(NSUInteger)page;
- (void)updateLocation;

@end

@implementation ListenViewController

@synthesize bgView = _bgView;
@synthesize meterView;
@synthesize pageView = _pageView;
@synthesize scrollView = _scrollView;
@synthesize samplingView = _samplingView;
@synthesize recordView;
@synthesize locationView;
@synthesize ledView = _ledView;
@synthesize dbLabel;
@synthesize descriptionLabel;
@synthesize takeButton;
@synthesize extendButton;
@synthesize qualifyButton;
@synthesize qualifyView;

@synthesize noiseRecorder = _noiseRecorder;
@synthesize locationManager = _locationManager;
@synthesize samplingTimer;

@synthesize currentLocation;

#pragma marl - IBAction methods

- (IBAction)action:(id)sender
{
    [(UIButton *)sender setSelected:YES];
    if (sender == self.qualifyButton) {
        [self scrollToPage:1];
        return;
    }
    
    self.takeButton.userInteractionEnabled = NO;
    self.extendButton.userInteractionEnabled = NO;
    self.extendButton.userInteractionEnabled = NO;
    self.recordView.hidden = NO;
    
    [self.noiseRecorder recordForDuration:5];
    [self updateLocation];
}

- (IBAction)clear:(id)sender
{
    self.noiseRecorder = [[[WTNoiseRecorder alloc] init] autorelease];
    self.noiseRecorder.delegate = self;
    self.noiseRecorder.samplesPerSecond = 20;
    
    self.meterView.image = [UIImage imageNamed:@"noise_meter.png"];
    self.dbLabel.text = @"";
    self.descriptionLabel.text = @"";
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
    } else {
        [typeButton setSelected:YES];
    }
}

- (IBAction)sendReport:(id)sender
{
    [(UIButton *)sender setSelected:YES];
    [[[[UIAlertView alloc] initWithTitle:@"Beta Release" 
                               message:@"This feature is not yet implemented!" 
                              delegate:nil 
                     cancelButtonTitle:@"OK" 
                     otherButtonTitles:nil] autorelease] show];
}

#pragma mark - Private methods

- (void)scrollToPage:(NSUInteger)page
{
    [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.frame.size.width * page, 
                                                    0, 
                                                    self.scrollView.frame.size.width, 
                                                    self.scrollView.frame.size.height) 
                                animated:YES];
    NSString *imageName = [NSString stringWithFormat:@"page_%d.png", page+1];
    self.pageView.image = [UIImage imageNamed:imageName];
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
        [self.locationManager startUpdatingLocation];
    }
}

#pragma marl - CoreLocation delegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (newLocation.horizontalAccuracy >= 0 && newLocation.horizontalAccuracy < 100) {
        self.currentLocation = newLocation;
        [manager stopUpdatingLocation];
        
        self.locationView.hidden = NO;
    }    
}

#pragma mark - WTLedViewDataSource methods

- (CGFloat)ledView:(WTLedView *)ledView valueForColumnAtIndex:(NSUInteger)index
{
    WTNoise *noise = self.noiseRecorder.recordedNoise;
    NSUInteger totalSamples = self.noiseRecorder.samplesPerSecond * self.noiseRecorder.recordingDuration;
    if (totalSamples == 0) {
        return 0;
    }
    
    float len = totalSamples / (float)ledView.numberOfCols;
    float level = 0.0;
    for (NSUInteger i=0; i<ceilf(len); i++) {
        NSUInteger j = (int)(len*index) + i;
        if (j < [noise.samples count]) {
            level += [(NSNumber *)[noise.samples objectAtIndex:j] floatValue];
        } else {
            return 0;
        }
    }
    
    return level / (120.0 * ceil(len));
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSUInteger page = floorf(CGRectGetMinX(scrollView.bounds) / CGRectGetWidth(scrollView.bounds)) + 1;
    NSString *imageName = [NSString stringWithFormat:@"page_%d.png", page];
    self.pageView.image = [UIImage imageNamed:imageName];
}

#pragma mark - WTNoiseRecorderDelegate methods

- (void)noiseRecorder:(WTNoiseRecorder *)noiseRecorder didUpdateNoise:(WTNoise *)noise
{        
    [self.ledView setNeedsDisplay];  
}

- (void)noiseRecorderDidFinishRecording:(WTNoiseRecorder *)noiseRecorder
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    self.recordView.hidden = YES;
    
    float db = noiseRecorder.recordedNoise.averageLevel;
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
    
    self.meterView.image = [UIImage imageNamed:imageName];
    self.dbLabel.text = [NSString stringWithFormat:@"%ddb", (int)noiseRecorder.recordedNoise.averageLevel];
    self.descriptionLabel.text = description;
    
    self.takeButton.userInteractionEnabled = YES;
    self.extendButton.userInteractionEnabled = YES;
    self.extendButton.userInteractionEnabled = YES;
    
    [self.takeButton setSelected:NO];
    [self.extendButton setSelected:NO];
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
    [recordView release];
    [locationView release];
    [meterView release];
    [_ledView release];
    [dbLabel release];
    [descriptionLabel release];
    [takeButton release];
    [extendButton release];
    [qualifyButton release];
    [qualifyView release];
    
    [_noiseRecorder release];
    [_locationManager release];
    
    [currentLocation release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 3, self.scrollView.frame.size.height);
    self.samplingView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.qualifyView.frame = CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [self.scrollView addSubview:self.samplingView];
    [self.scrollView addSubview:self.qualifyView];
    
    self.ledView.dataSource = self;
    self.ledView.ledColor = [UIColor colorWithRed:1.0 green:172.0/255.0 blue:83.0/255.0 alpha:1.0];
    
    UIColor *ledColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pixel_pattern.png"]];
    self.dbLabel.textColor = ledColor;
    self.descriptionLabel.textColor = ledColor;

    self.recordView.hidden = YES;
    self.locationView.hidden = YES;

    [self clear:nil];
    
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.bgView = nil;
    self.pageView = nil;
    self.scrollView = nil;
    self.samplingView = nil;
    self.recordView = nil;
    self.locationView = nil;
    self.meterView = nil;
    self.ledView = nil;
    self.dbLabel = nil;
    self.descriptionLabel = nil;
    self.takeButton = nil;
    self.extendButton = nil;
    self.qualifyButton = nil;
    self.qualifyView = nil;
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

@end
