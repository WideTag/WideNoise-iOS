//
//  WTNoiseRecorder.h
//  WideNoise
//
//  Created by Emilio Pavia on 24/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

#import "WTNoise.h"

@class WTNoiseRecorder;

@protocol WTNoiseRecorderDelegate <NSObject>

- (void)noiseRecorderDidFinishRecording:(WTNoiseRecorder *)noiseRecorder;
- (void)noiseRecorder:(WTNoiseRecorder *)noiseRecorder didUpdateNoise:(WTNoise *)noise;

@optional

- (void)noiseRecorderErrorDidOccurr:(WTNoiseRecorder *)noiseRecorder error:(NSError *)error;

@end

@interface WTNoiseRecorder : NSObject <AVAudioRecorderDelegate>

@property (nonatomic, assign) id <WTNoiseRecorderDelegate> delegate;
@property (nonatomic, assign) NSUInteger samplesPerSecond;
@property (nonatomic, readonly) NSTimeInterval recordingDuration;
@property (nonatomic, readonly) WTNoise *recordedNoise;

- (BOOL)recordForDuration:(NSTimeInterval)duration;
- (void)stop;
- (void)clear;

@end
