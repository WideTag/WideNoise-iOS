//
//  WTReferenceRequestFactory.m
//  WideNoise
//
//  Created by Emilio Pavia on 30/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "WTReferenceRequestFactory.h"

#import "NSString+HMAC.h"
#import "SBJson.h"

#define REPORTING_URL @"http://widenoise.com/report"
#define MAP_URL @"http://widenoise.com/map"

#define REQUEST_TIMEOUT 30.0

@implementation WTReferenceRequestFactory

#pragma mark - Public methods

- (NSURLRequest *)requestForReportingNoise:(WTNoise *)noise date:(NSDate *)date
{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setObject:[NSString stringWithFormat:@"%d", (int)[date timeIntervalSince1970]] forKey:@"unixtime"];
    [data setObject:[NSString stringWithFormat:@"%f", noise.location.coordinate.latitude] forKey:@"lat"];
    [data setObject:[NSString stringWithFormat:@"%f", noise.location.coordinate.longitude] forKey:@"lon"];
    [data setObject:[NSString stringWithFormat:@"%f", noise.averageLevel] forKey:@"rms"];
    [data setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"uid"];
    [data setObject:noise.types forKey:@"types"];
    if (noise.tags != nil) {
        [data setObject:noise.tags forKey:@"tags"];
    }    
    [data setObject:@"" forKey:@"hash"];

    [data setObject:[[data JSONRepresentation] HMACUsingSHA256WithKey:API_SHARED_KEY] forKey:@"hash"];
    
    NSString *jsonString = [data JSONRepresentation];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:REPORTING_URL]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
                                                       timeoutInterval:REQUEST_TIMEOUT];
    
    NSData *jsonData = [NSData dataWithBytes:[jsonString cStringUsingEncoding:NSUTF8StringEncoding] length:[jsonString length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    return request;
}

- (NSURLRequest *)requestForFetchingNoiseReportsInMapRect:(MKMapRect)mapRect
{
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setObject:[NSString stringWithFormat:@"%f", region.center.latitude] forKey:@"lat"];
    [data setObject:[NSString stringWithFormat:@"%f", region.center.longitude] forKey:@"lon"];
    [data setObject:[NSString stringWithFormat:@"%f", region.span.latitudeDelta] forKey:@"lat_delta"];
    [data setObject:[NSString stringWithFormat:@"%f", region.span.longitudeDelta] forKey:@"lon_delta"];
    [data setObject:@"" forKey:@"hash"];
    
    [data setObject:[[data JSONRepresentation] HMACUsingSHA256WithKey:API_SHARED_KEY] forKey:@"hash"];
    
    NSString *jsonString = [data JSONRepresentation];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MAP_URL]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
                                                       timeoutInterval:REQUEST_TIMEOUT];
    
    NSData *jsonData = [NSData dataWithBytes:[jsonString cStringUsingEncoding:NSUTF8StringEncoding] length:[jsonString length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    return request;
}

#pragma mark -

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
