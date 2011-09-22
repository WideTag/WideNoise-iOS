//
//  WTRequestFactory.m
//  WideNoise
//
//  Created by Emilio Pavia on 24/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "WTRequestFactory.h"

#import "WTReferenceRequestFactory.h"

@implementation WTRequestFactory

+ (WTRequestFactory *)factory
{
    // Modify this method to use your own implementation of APIs.
#if defined (USE_REFERENCE_API)
    return [[[WTReferenceRequestFactory alloc] init] autorelease];
#else
    return nil;
#endif
}

- (NSURLRequest *)requestForReportingNoise:(WTNoise *)noise date:(NSDate *)date
{
    return nil;
}

- (NSURLRequest *)requestForFetchingNoiseReportsInMapRect:(MKMapRect)mapRect
{
    return nil;
}

- (NSURLRequest *)requestForAssigningTags:(NSArray *)tags toNoise:(WTNoise *)noise
{
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
