//
//  WTNoise.h
//  WideNoise
//
//  Created by Emilio Pavia on 23/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;

/*
 *  WTNoise
 *  
 *  Discussion:
 *    Represents a noise measure along with geographical information.
 */
@interface WTNoise : NSObject  {
@private
    NSMutableArray *_samples;
}

/*
 *  samples
 *  
 *  Discussion:
 *    Returns an array of all recorded samples. Each element of the array is
 *    a NSNumber object.
 */
@property (nonatomic, readonly) NSArray *samples;

/*
 *  averageLevel
 *  
 *  Discussion:
 *    Returns the average level of all samples.
 *
 *  Range:
 *    0.0 - 120.0 dB
 */
@property (nonatomic, readonly) float averageLevel;

/*
 *  location
 *  
 *  Discussion:
 *    Contains the geographical coordinates of the recorded noise.
 */
@property (nonatomic, retain) CLLocation *location;

/*
 *  addSample:
 *  
 *  Discussion:
 *    Adds a sample to calculate the average noise level. A value of 0 dB indicates 
 *    minimum power (that is, near silence); a value of 120 dB indicates full scale,
 *    or maximum power. Out of range values will be given the nearest valid value.
 */
- (void)addSample:(float)level;

@end
