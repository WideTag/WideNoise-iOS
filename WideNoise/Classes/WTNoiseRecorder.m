//
//  WTNoiseRecorder.m
//  WideNoise
//
//  Created by Emilio Pavia on 24/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "WTNoiseRecorder.h"

#import "functions.h"

@interface WTNoiseRecorder ()

@property (nonatomic, retain) AVAudioRecorder *audioRecorder;
@property (nonatomic, assign) NSTimer *samplingTimer;
@property (nonatomic, assign) NSUInteger recordingDuration;
@property (nonatomic, retain) WTNoise *recordedNoise;

@property (nonatomic, readonly) NSUInteger numberOfSamples;

- (void)recordSample;

@end

@implementation WTNoiseRecorder

@synthesize delegate;
@synthesize samplesPerSecond;

@synthesize audioRecorder = _audioRecorder;
@synthesize samplingTimer = _samplingTimer;
@synthesize recordingDuration = _recordingDuration;
@synthesize recordedNoise = _recordedNoise;

#pragma mark - Properties

- (NSUInteger)numberOfSamples
{
    return self.recordingDuration * self.samplesPerSecond;
}

#pragma mark - Public methods

- (BOOL)recordForDuration:(NSTimeInterval)duration
{
    if (self.audioRecorder.recording || duration <= 0) {
        return NO;
    }
    
    self.recordingDuration = duration;
    self.recordedNoise = [[[WTNoise alloc] init] autorelease];
    self.samplingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/self.samplesPerSecond 
                                                          target:self
                                                        selector:@selector(recordSample) 
                                                        userInfo:nil 
                                                         repeats:YES];
    
    return [self.audioRecorder record];
}

- (void)stop
{
    [self.audioRecorder stop];
    [self.audioRecorder deleteRecording];
}

#pragma mark - Private methods

- (void)recordSample
{
    if (self.audioRecorder.recording) {
        [self.audioRecorder updateMeters];
        
        // convert the non-linear dB value to a linear one in [0,1]
        float level = pow(10, (0.05 * [self.audioRecorder averagePowerForChannel:0]));
        // use this table to convert from raw mic level to dB SPL
        Float32 lookup_table[][2] = {
            {0.0, 0.0},
            {0.003, 50},
            {0.0046, 55},
            {0.009, 60},
            {0.016, 65},
            {0.031, 70},
            {0.052, 75},
            {0.085, 80},
            {0.15, 85},
            {0.25, 90},
            {0.5, 95},
            {0.8, 100},
            {0.9, 110},
            {1, 120}
        };
        level = interpolate(level, lookup_table, 14);
        
        [self.recordedNoise addSample:level];
        [self.delegate noiseRecorder:self didRecordSampleWithLevel:level];
        
        if ([self.recordedNoise.samples count] >= self.numberOfSamples) {
            [self stop];
        }
    }
}

#pragma mark - AVAudioRecorderDelegate methods

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [self.samplingTimer invalidate];
    self.samplingTimer = nil;
    
    [self.delegate noiseRecorder:self didFinishRecordingNoise:self.recordedNoise];   
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(noiseRecorderErrorDidOccurr:error:)]) {
        [self.delegate noiseRecorderErrorDidOccurr:self error:error];
    }
}

#pragma mark - 

- (id)init
{
    self = [super init];
    if (self) {
        NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"recording.caf"]];
        NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                  [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                  [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                  [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                  nil];
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:nil];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
        
        self.samplesPerSecond = 1;
        self.recordingDuration = 0.0;
    }
    
    return self;
}

- (void)dealloc
{
    [_audioRecorder release];
    [_samplingTimer release];
    [_recordedNoise release];
    [super dealloc];
}

@end
