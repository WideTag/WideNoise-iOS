//
//  ListenViewController.m
//  WideNoise
//
//  Created by Emilio Pavia on 24/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "ListenViewController.h"

@interface ListenViewController ()

@property (nonatomic, retain) WTNoiseRecorder *noiseRecorder;

@end

@implementation ListenViewController

@synthesize takeButton;
@synthesize extendButton;
@synthesize qualifyButton;

@synthesize noiseRecorder = _noiseRecorder;

#pragma marl - IBAction methods

- (IBAction)takeNoiseSample:(id)sender
{
    self.noiseRecorder = [[WTNoiseRecorder alloc] init];
    self.noiseRecorder.delegate = self;
    self.noiseRecorder.samplesPerSecond = 1;
    
    [self.noiseRecorder recordForDuration:10];
}

- (IBAction)extendSampling:(id)sender
{
    
}

- (IBAction)qualifyNoise:(id)sender
{
    
}

#pragma mark - WTNoiseRecorderDelegate methods

- (void)noiseRecorder:(WTNoiseRecorder *)noiseRecorder didRecordSampleWithLevel:(float)level
{
    NSLog(@"level: %f", level);
}

- (void)noiseRecorder:(WTNoiseRecorder *)noiseRecorder didFinishRecordingNoise:(WTNoise *)noise
{
    NSLog(@"average level: %f", noise.averageLevel);
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
    [takeButton release];
    [extendButton release];
    [qualifyButton release];
    [_noiseRecorder release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.takeButton = nil;
    self.extendButton = nil;
    self.qualifyButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
