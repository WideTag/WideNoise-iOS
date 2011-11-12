//
//  WTNoise.m
//  WideNoise
//
//  Created by Emilio Pavia on 23/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "WTNoise.h"

#import "functions.h"
#import "SBJson.h"
#import "NSURLConnection+Blocks.h"
#import "WTRequestFactory.h"

// use this table to convert from raw mic level to dB SPL
static Float32 lookup_table[][2] = {
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

#define kLookupTableSize 14

@interface WTNoise ()

- (BOOL)isEqualToNoise:(WTNoise *)aNoise;

@end

@implementation WTNoise

@synthesize identifier = _identifier;
@synthesize location = _location;
@synthesize measurementDate = _measurementDate;
@synthesize measurementDuration = _measurementDuration;
@synthesize perceptions = _perceptions;
@synthesize tags = _tags;

@synthesize fetchedAverageLevel;

#pragma mark - Properties

- (NSArray *)samples
{
    NSArray *samples = [[NSArray alloc] initWithArray:_samples];
    return [samples autorelease];
}

- (float)averageLevel
{
    float averageLevel = 0.0;
    for (NSNumber *sample in _samples) {
        averageLevel += [sample floatValue];
    }
    return averageLevel / [_samples count];
}

- (float)averageLevelInDB
{
    if (self.fetchedAverageLevel < 0) {
        return interpolate([self averageLevel], lookup_table, kLookupTableSize);
    }
    
    return self.fetchedAverageLevel;
}

- (UIImage *)icon
{
    float db = self.averageLevelInDB;
    NSString *imageName = nil;
    if (db <= 30) {
		imageName = @"icon_1.png";
	} else if (db <= 60) {
		imageName = @"icon_2.png";
	} else if (db <= 70) {
		imageName = @"icon_3.png";
	} else if (db <= 90) {
		imageName = @"icon_4.png";
	} else if (db <= 100) {
		imageName = @"icon_5.png";
	} else if (db <= 115) {
		imageName = @"icon_6.png";
	} else {
		imageName = @"icon_7.png";
	}
    
    return [UIImage imageNamed:imageName];
}

#pragma mark - Public methods

- (void)addSample:(float)level
{
    if (level < 0.0) {
        level = 0.0;
    } else if (level > 1.0) {
        level = 1.0;
    }
    [_samples addObject:[NSNumber numberWithFloat:level]];
}

- (float)rawSampleAtIndex:(NSUInteger)index
{
    float sample = 0.0f;
    if (index < [_samples count]) {
        sample = [(NSNumber *)[_samples objectAtIndex:index] floatValue];
    }
    return sample;
}

- (float)sampleAtIndex:(NSUInteger)index
{
    return interpolate([self rawSampleAtIndex:index], lookup_table, kLookupTableSize);
}

- (void)setFeelingLevel:(float)level
{
    [_perceptions setObject:[NSString stringWithFormat:@"%.1f", (round(level * 10) / 10.0)] forKey:@"feeling"];
}

- (void)setDisturbanceLevel:(float)level
{
    [_perceptions setObject:[NSString stringWithFormat:@"%.1f", (round(level * 10) / 10.0)] forKey:@"disturbance"];
}

- (void)setIsolationLevel:(float)level
{
    [_perceptions setObject:[NSString stringWithFormat:@"%.1f", (round(level * 10) / 10.0)] forKey:@"isolation"];
}

- (void)setArtificialityLevel:(float)level
{
    [_perceptions setObject:[NSString stringWithFormat:@"%.1f", (round(level * 10) / 10.0)] forKey:@"artificiality"];
}

- (NSString *)description
{
    float db = self.averageLevelInDB;
    NSString *description;    
    if (db <= 10) {
        description = @"silence";
    } else if (db <= 30) {
        description = @"feather noise";
    } else if (db <= 60) {
        description = @"sleeping cat noise";
    } else if (db <= 70) {
        description = @"television noise";
    } else if (db <= 90) {
        description = @"car noise";
    } else if (db <= 100) {
        description = @"dragster noise";
    } else if (db <= 115) {
        description = @"t-rex noise";
    } else if (db > 115) {
        description = @"rock concert noise";
    }
    
    return description;
}

#pragma mark Class methods

+ (void)processReportedNoisesInMapRect:(MKMapRect)mapRect withBlock:(void (^)(NSArray *noises, float averageLevel))processNoises
{
    [NSURLConnection sendAsynchronousRequest:[[WTRequestFactory factory] requestForFetchingNoiseReportsInMapRect:mapRect] 
                                   onSuccess:^(NSData *data, NSURLResponse *response) {
                                       NSString *responseString = [[NSString alloc] initWithBytes:[data bytes]
                                                                                           length:[data length] 
                                                                                         encoding:NSUTF8StringEncoding];
                                       NSDictionary *responseJSON = [responseString JSONValue];
                                       
                                       float averageLevel = [[responseJSON objectForKey:@"average_db"] floatValue];
                                       NSMutableArray *noises = [NSMutableArray array];
                                       NSDictionary *fetchedNoises = nil;
                                       if ([[responseJSON objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                                           fetchedNoises = (NSDictionary *)[responseJSON objectForKey:@"data"];
                                       }
                                       for (NSString *noiseID in [fetchedNoises allKeys]) {
                                           NSDictionary *noise = [fetchedNoises objectForKey:noiseID];
                                           WTNoise *noiseObject = [[[WTNoise alloc] init] autorelease];
                                           noiseObject.identifier = noiseID;
                                           noiseObject.measurementDate = [NSDate dateWithTimeIntervalSince1970:[[noise objectForKey:@"timestamp"] doubleValue]];
                                           noiseObject.measurementDuration = [[noise objectForKey:@"duration"] doubleValue];
                                           NSArray *coordinates = (NSArray *)[noise objectForKey:@"geo_coord"];
                                           noiseObject.location = [[[CLLocation alloc] initWithLatitude:[[coordinates objectAtIndex:1] doubleValue] longitude:[[coordinates objectAtIndex:0] doubleValue]] autorelease];
                                           noiseObject.fetchedAverageLevel = [[noise objectForKey:@"average_db"] floatValue];

                                           [noises addObject:noiseObject];
                                       }
                                       
                                       processNoises([NSArray arrayWithArray:noises], averageLevel);
                                       
                                       // NSLog(@"%@", responseJSON);
                                   }
                                   onFailure:^(NSData *data, NSError *error) {
                                       processNoises(nil, 0.0);
                                   }];
}

#pragma mark - MKAnnotation protocol methods

- (CLLocationCoordinate2D)coordinate
{
    return self.location.coordinate;
}

- (NSString *)title
{
    return [NSString stringWithFormat:@"%ddb - %d\"", (int)self.fetchedAverageLevel, (int)self.measurementDuration];
}

- (NSString *)subtitle
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    NSString *formattedDate = [dateFormatter stringFromDate:self.measurementDate];
    [dateFormatter release];
    
    return formattedDate;
}

#pragma mark -

- (id)init
{
    self = [super init];
    if (self) {
        _samples = [[NSMutableArray alloc] init];
        _perceptions = [[NSMutableDictionary alloc] init];
        
        fetchedAverageLevel = -1;
    }
    
    return self;
}

- (BOOL)isEqual:(id)other 
{
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToNoise:other];
}

- (BOOL)isEqualToNoise:(WTNoise *)aNoise 
{
    if (self == aNoise)
        return YES;
    if (![(id)[self identifier] isEqual:[aNoise identifier]])
        return NO;
    return YES;
}

- (NSUInteger)hash 
{
    int prime = 31;
    int result = 1;
    result = prime * result + [_identifier hash];
    return result;
}

- (void)dealloc
{
    [_identifier release];
    [_samples release];
    [_location release];
    [_measurementDate release];
    [_tags release];
    [_perceptions release];
    [super dealloc];
}

@end