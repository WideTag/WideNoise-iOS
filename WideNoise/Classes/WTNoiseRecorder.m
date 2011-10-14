//
//  WTNoiseRecorder.m
//  WideNoise
//
//  Created by Emilio Pavia on 24/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "WTNoiseRecorder.h"

@interface WTNoiseRecorder ()

@property (nonatomic, retain) AVAudioRecorder *audioRecorder;
@property (nonatomic, assign) NSTimer *samplingTimer;

@property (nonatomic, readonly) NSUInteger numberOfSamples;

- (void)recordSample;

@end

@implementation WTNoiseRecorder

@synthesize delegate;
@synthesize samplesPerSecond;
@synthesize recordedNoise = _recordedNoise;

@synthesize audioRecorder = _audioRecorder;
@synthesize samplingTimer = _samplingTimer;
@synthesize recordingDuration = _recordingDuration;

#pragma mark - Properties

- (NSUInteger)numberOfSamples
{
    return self.recordingDuration * self.samplesPerSecond;
}

#pragma mark - Public methods

- (BOOL)recordForDuration:(NSTimeInterval)duration
{
    if (duration <= 0) {
        return NO;
    }
    
    _recordingDuration += duration;
    
    if (self.audioRecorder.recording) {
        return YES;
    }    
    
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
}

- (void)clear
{
    if (!self.audioRecorder.recording) {
        [_recordedNoise release];
        _recordedNoise = [[WTNoise alloc] init];
        _recordingDuration = 0.0;
        
        [self.audioRecorder deleteRecording];
    }    
}

#pragma mark - Private methods

- (void)recordSample
{
    if (self.audioRecorder.recording && [self.recordedNoise.samples count] < self.numberOfSamples) {
        [self.audioRecorder updateMeters];
        
        // convert the non-linear dB value to a linear one in [0,1]
        float level = pow(10, (0.05 * [self.audioRecorder averagePowerForChannel:0]));
        
        [self.recordedNoise addSample:level];
        [self.delegate noiseRecorder:self didUpdateNoise:self.recordedNoise];
    } else {
        [self.samplingTimer invalidate];
        self.samplingTimer = nil;
        
        [self stop];
    }
}

#pragma mark - AVAudioRecorderDelegate methods

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    self.recordedNoise.measurementDuration = self.recordingDuration;
    
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(noiseRecorderDidFinishRecording:) withObject:self waitUntilDone:NO];
    [recorder deleteRecording];
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
        
        _recordedNoise = [[WTNoise alloc] init];
        
        self.samplesPerSecond = 1;
        _recordingDuration = 0.0;
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
