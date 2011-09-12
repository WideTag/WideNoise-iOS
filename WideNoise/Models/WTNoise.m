//
//  WTNoise.m
//  WideNoise
//
//  Created by Emilio Pavia on 23/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "WTNoise.h"

@implementation WTNoise

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

- (MKCircle *)overlayCircle
{
    return [[[MKCircle circleWithCenterCoordinate:self.location.coordinate radius:pow(self.averageLevel/30.0, 3.0)/3.0] retain] autorelease];
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

- (UIImage *)icon
{
    float db = self.averageLevel;
    NSString *imageName = nil;
    if (db <= 30) {
		imageName = @"feather_icon.png";
	} else if (db <= 60) {
		imageName = @"cat_icon.png";
	} else if (db <= 70) {
		imageName = @"tv_icon.png";
	} else if (db <= 90) {
		imageName = @"car_icon.png";
	} else if (db <= 100) {
		imageName = @"dragster_icon.png";
	} else if (db <= 115) {
		imageName = @"t-rex_icon.png";
	} else {
		imageName = @"concert_icon.png";
	}
    
    return [UIImage imageNamed:imageName];
}

#pragma mark - MKAnnotation and MKOverlay protocol methods

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

- (MKMapRect)boundingMapRect
{
    MKMapPoint mapPoint = MKMapPointForCoordinate(self.location.coordinate);
    return MKMapRectMake(mapPoint.x, mapPoint.y, 100, 100);
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

- (void)dealloc
{
    [_samples release];
    [_location release];
    [_measurementDate release];
    [_types release];
    [_tags release];
    [super dealloc];
}

@end