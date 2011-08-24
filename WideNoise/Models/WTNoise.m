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

#pragma mark -

- (id)init
{
    self = [super init];
    if (self) {
        _samples = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_samples release];
    [_location release];
    [super dealloc];
}

@end