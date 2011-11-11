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
    NSMutableDictionary *_perceptions;
}

/*
 *  identifier
 *  
 *  Discussion:
 *    A unique ID used to identify a noise reported to the server.
 */
@property (nonatomic, copy) NSString *identifier;

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
 *    Returns the average raw level of all samples.
 *
 *  Range:
 *    0.0 - 1.0
 */
@property (nonatomic, readonly) float averageLevel;

/*
 *  averageLevelInDB
 *  
 *  Discussion:
 *    Returns the average level of all samples.
 *
 *  Range:
 *    0.0 - 120.0 dB
 */
@property (nonatomic, readonly) float averageLevelInDB;

@property (nonatomic, assign) float fetchedAverageLevel;

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
 *  measurementDuration
 *  
 *  Discussion:
 *    Contains the duration in seconds of the recorded noise.
 */
@property (nonatomic, assign) NSTimeInterval measurementDuration;

/*
 *  perceptions
 *  
 *  Discussion:
 *    Contains values that define how the user perceived the noise.
 */
@property (nonatomic, readonly) NSDictionary *perceptions;

/*
 *  tags
 *  
 *  Discussion:
 *    Contains values that can be defined by the user to categorize the noise.
 */
@property (nonatomic, retain) NSArray *tags;

/*
 *  icon:
 *  
 *  Discussion:
 *    Returns an iconic representation for the noise level.
 */
@property (nonatomic, readonly) UIImage *icon;

/*
 *  addSample:
 *  
 *  Discussion:
 *    Adds a sample to calculate the average noise level. A value of 0 dB indicates 
 *    minimum power (that is, near silence); a value of 120 dB indicates full scale,
 *    or maximum power. Out of range values will be given the nearest valid value.
 */
- (void)addSample:(float)level;

- (float)rawSampleAtIndex:(NSUInteger)index;
- (float)sampleAtIndex:(NSUInteger)index;

- (void)setFeelingLevel:(float)level;
- (void)setDisturbanceLevel:(float)level;
- (void)setIsolationLevel:(float)level;
- (void)setArtificialityLevel:(float)level;

+ (void)processReportedNoisesInMapRect:(MKMapRect)mapRect withBlock:(void (^)(NSArray *noises, float averageLevel))processNoises;

@end
