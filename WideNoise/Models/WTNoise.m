//
//  WTNoise.m
//  WideNoise
//
//  Created by Emilio Pavia on 23/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "WTNoise.h"

#import "SBJson.h"
#import "NSURLConnection+Blocks.h"
#import "WTRequestFactory.h"

@interface WTNoise ()

- (BOOL)isEqualToNoise:(WTNoise *)aNoise;

@end

@implementation WTNoise

@synthesize identifier = _identifier;
@synthesize location = _location;
@synthesize measurementDate = _measurementDate;
@synthesize tags = _tags;

#pragma mark - Properties

- (NSArray *)samples
{
    NSArray *samples = [[NSArray alloc] initWithArray:_samples];
    return [samples autorelease];
}

- (NSArray *)types
{
    NSSet *types = [[NSArray alloc] initWithArray:_types];
    return [types autorelease];
}

- (float)averageLevel
{
    float averageLevel = 0.0;
    for (NSNumber *sample in _samples) {
        averageLevel += [sample floatValue];
    }
    return averageLevel / [_samples count];
}

- (UIImage *)icon
{
    float db = self.averageLevel;
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
    } else if (level > 120.0) {
        level = 120.0;
    }
    [_samples addObject:[NSNumber numberWithFloat:level]];
}

- (void)addType:(NSString *)type
{
    [_types addObject:type];
}

- (NSString *)description
{
    NSString *description;
    
    if (self.averageLevel <= 10) {
        description = @"silence";
    } else if (self.averageLevel <= 30) {
        description = @"feather noise";
    } else if (self.averageLevel <= 60) {
        description = @"sleeping cat noise";
    } else if (self.averageLevel <= 70) {
        description = @"television noise";
    } else if (self.averageLevel <= 90) {
        description = @"car noise";
    } else if (self.averageLevel <= 100) {
        description = @"dragster noise";
    } else if (self.averageLevel <= 115) {
        description = @"t-rex noise";
    } else if (self.averageLevel > 115) {
        description = @"rock concert noise";
    }
    
    return description;
}

#pragma mark Class methods

+ (void)processReportedNoisesInMapRect:(MKMapRect)mapRect withBlock:(void (^)(NSArray *noises))processNoises
{
    NSMutableArray *noises = [NSMutableArray arrayWithCapacity:10];
    for (int i=0; i<10; i++) {
        WTNoise *noise = [[[WTNoise alloc] init] autorelease];
        MKMapPoint randomPoint = MKMapPointMake(mapRect.origin.x + (((double)rand()/(double)RAND_MAX)*mapRect.size.width), mapRect.origin.y + (((double)rand()/(double)RAND_MAX)*mapRect.size.height));
        CLLocationCoordinate2D randomCoordinate = MKCoordinateForMapPoint(randomPoint);
        noise.location = [[[CLLocation alloc] initWithLatitude:randomCoordinate.latitude longitude:randomCoordinate.longitude] autorelease];
        [noise addSample:((double)rand()/(double)RAND_MAX)*120.0];
        noise.measurementDate = [NSDate date];
        [noises addObject:noise];
    }
    processNoises(noises);
    /*
    [NSURLConnection sendAsynchronousRequest:[[WTRequestFactory factory] requestForFetchingNoiseReportsInMapRect:mapRect] 
                                   onSuccess:^(NSData *data, NSURLResponse *response) {
                                       NSString *responseString = [[NSString alloc] initWithBytes:[data bytes]
                                                                                           length:[data length] 
                                                                                         encoding:NSUTF8StringEncoding];
                                       NSDictionary *responseJSON = [responseString JSONValue];
                                       if ([[responseJSON objectForKey:@"status"] intValue] == 0) {
                                           NSMutableArray *noises = [NSMutableArray array];
                                           NSArray *fetchedNoises = (NSArray *)[responseJSON objectForKey:@"data"];
                                           for (id noise in fetchedNoises) {
                                               if ([noise isKindOfClass:[NSDictionary class]]) {
                                                   WTNoise *noiseObject = [[[WTNoise alloc] init] autorelease];
                                                   noiseObject.identifier = [noise objectForKey:@"id"];
                                                   noiseObject.measurementDate = [NSDate dateWithTimeIntervalSince1970:[[noise objectForKey:@"timestamp"] doubleValue]];
                                                   noiseObject.location = [[[CLLocation alloc] initWithLatitude:[[noise objectForKey:@"lat"] doubleValue] longitude:[[noise objectForKey:@"lon"] doubleValue]] autorelease];
                                                   [noiseObject addSample:[[noise objectForKey:@"db"] floatValue]];
                                                   [noises addObject:noiseObject];
                                               }
                                           }
                                           processNoises([NSArray arrayWithArray:noises]);
                                       } else {
                                           NSLog(@"An error occurred when trying to fetch reported noises (status = %@)", [responseJSON objectForKey:@"status"]);
                                           processNoises(nil);
                                       }                                       
                                   }
                                   onFailure:^(NSData *data, NSError *error) {
                                       processNoises(nil);
                                   }];
     */
}

#pragma mark - MKAnnotation protocol methods

- (CLLocationCoordinate2D)coordinate
{
    return self.location.coordinate;
}

- (NSString *)title
{
    return [NSString stringWithFormat:@"%ddb", (int)self.averageLevel];
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
        _types = [[NSMutableArray alloc] init];
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
    [_types release];
    [_tags release];
    [super dealloc];
}

@end