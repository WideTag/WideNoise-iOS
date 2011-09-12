//
//  WTNoise.h
//  WideNoise
//
//  Created by Emilio Pavia on 23/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

/*
 *  WTNoise
 *  
 *  Discussion:
 *    Represents a noise measure along with geographical information.
 */
@interface WTNoise : NSObject <MKAnnotation> {
@private
    NSMutableArray *_samples;
    NSMutableArray *_types;
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
 *  measurementDate
 *  
 *  Discussion:
 *    Contains the date of when the noise was measured.
 */
@property (nonatomic, retain) NSDate *measurementDate;

/*
 *  types
 *  
 *  Discussion:
 *    Contains values from a predefined set selected by the user to categorize the noise.
 */
@property (nonatomic, readonly) NSArray *types;

/*
 *  tags
 *  
 *  Discussion:
 *    Contains values that can be defined by the user to categorize the noise.
 */
@property (nonatomic, retain) NSArray *tags;

/*
 *  addSample:
 *  
 *  Discussion:
 *    Adds a sample to calculate the average noise level. A value of 0 dB indicates 
 *    minimum power (that is, near silence); a value of 120 dB indicates full scale,
 *    or maximum power. Out of range values will be given the nearest valid value.
 */
- (void)addSample:(float)level;

/*
 *  addType:
 *  
 *  Discussion:
 *    Assigns a type to the noise.
 */
- (void)addType:(NSString *)type;

- (UIImage *)icon;

@end
