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
#import "UIDevice+IdentifierAddition.h"

#define REPORTING_URL @"http://widenoise.com/report"
#define MAP_URL @"http://widenoise.com/map"
#define TAGS_URL @"http://widenoise.com/tags"

#define REQUEST_TIMEOUT 30.0

@implementation WTReferenceRequestFactory

#pragma mark - Public methods

- (NSURLRequest *)requestForReportingNoise:(WTNoise *)noise date:(NSDate *)date
{
    int interval = (int)([noise.samples count] / (2*noise.measurementDuration));
    NSMutableArray *samples = [NSMutableArray array];
    int i = 0;
    while (i < [noise.samples count]) {
        [samples addObject:[NSString stringWithFormat:@"%@", [noise.samples objectAtIndex:i]]];
        i += interval;
    }
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setObject:[NSString stringWithFormat:@"%d", (int)[date timeIntervalSince1970]] forKey:@"timestamp"];
    [data setObject:[NSString stringWithFormat:@"%.0f", noise.measurementDuration] forKey:@"duration"];
    [data setObject:[NSString stringWithFormat:@"%f", noise.location.coordinate.latitude] forKey:@"lat"];
    [data setObject:[NSString stringWithFormat:@"%f", noise.location.coordinate.longitude] forKey:@"lon"];
    [data setObject:[NSString stringWithFormat:@"%f", noise.averageLevel] forKey:@"average_raw"];
    [data setObject:[NSString stringWithFormat:@"%f", noise.averageLevelInDB] forKey:@"average_db"];
    [data setObject:[[UIDevice currentDevice] uniqueDeviceIdentifier] forKey:@"uid"];
    [data setObject:noise.perceptions forKey:@"perceptions"];
    [data setObject:samples forKey:@"samples"];
    [data setObject:[[UIDevice currentDevice] model] forKey:@"device"];
    [data setObject:@"" forKey:@"hash"];

    [data setObject:[[data JSONRepresentation] HMACUsingSHA256WithKey:API_SHARED_KEY] forKey:@"hash"];
    
    NSString *jsonString = [data JSONRepresentation];
    
    NSLog(@"%@", jsonString);

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

- (NSURLRequest *)requestForAssigningTags:(NSArray *)tags toNoise:(WTNoise *)noise
{
    if (noise.identifier == nil) {
        noise.identifier = @"test";
        //return nil;
    }
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setObject:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
    [data setObject:noise.identifier forKey:@"id"];
    if (tags == nil) {
        [data setObject:[NSArray array] forKey:@"tags"];
    } else {
        [data setObject:tags forKey:@"tags"];
    }
    [data setObject:[[UIDevice currentDevice] uniqueDeviceIdentifier] forKey:@"uid"];
    [data setObject:@"" forKey:@"hash"];
    
    [data setObject:[[data JSONRepresentation] HMACUsingSHA256WithKey:API_SHARED_KEY] forKey:@"hash"];
    
    NSString *jsonString = [data JSONRepresentation];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:TAGS_URL]
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
