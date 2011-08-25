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

- (void)noiseRecorder:(WTNoiseRecorder *)noiseRecorder didRecordSampleWithLevel:(float)level;
- (void)noiseRecorder:(WTNoiseRecorder *)noiseRecorder didFinishRecordingNoise:(WTNoise *)noise;

@optional

- (void)noiseRecorderErrorDidOccurr:(WTNoiseRecorder *)noiseRecorder error:(NSError *)error;

@end

@interface WTNoiseRecorder : NSObject <AVAudioRecorderDelegate>

@property (nonatomic, assign) id <WTNoiseRecorderDelegate> delegate;
@property (nonatomic, assign) NSUInteger samplesPerSecond;

- (BOOL)recordForDuration:(NSTimeInterval)duration;
- (void)stop;

@end
