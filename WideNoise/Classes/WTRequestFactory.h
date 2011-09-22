//
//  WTRequestFactory.h
//  WideNoise
//
//  Created by Emilio Pavia on 24/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WTNoise.h"

/*
 *  WTRequestFactory
 *  
 *  Discussion:
 *    Creates HTTP requests to interact with the APIs.
 */
@interface WTRequestFactory : NSObject

/*
 *  factory
 *  
 *  Discussion:
 *    Returns an implementation of this class. You can use your own backend by
 *    subclassing WTRequestFactory and implementing all its methods. Then modify
 *    this method to return an instance of your actual implementation.
 */
+ (WTRequestFactory *)factory;

/*
 *  requestForReportingNoise:date:
 *  
 *  Discussion:
 *    Returns a HTTP request object that can be used to report a noise to
 *    the server. The server must return a JSON response with a status field
 *    that indicates whether the request was successfully handled. Status codes are:
 *
 *       0: The request was succesfully handled.
 *     100: The server could not read the JSON object you provided.
 *     101: The request has an incorrect signature.
 *     102: The request was already sent to the server (duplicate).
 *
 *    The JSON response must contain a id field with the identifier assigned from the server
 *    to the provided noise.
 */
- (NSURLRequest *)requestForReportingNoise:(WTNoise *)noise date:(NSDate *)date;

/*
 *  requestForFetchingNoiseReportsInMapRect:
 *  
 *  Discussion:
 *    Returns a HTTP request object that can be used to fetch all noises
 *    reported inside the provided map area. The server must return a JSON response with a status field
 *    that indicates whether the request was successfully handled. Status codes are:
 *
 *       0: The request was succesfully handled.
 *     100: The server could not read the JSON object you provided.
 *     101: The request has an incorrect signature.
 *
 *    The JSON response must contain a data field with an array of all recorded noises.
 *    The fields of each noise are:
 *
 *           id: An identifier for the report (must be unique).
 *          lat: The latitude in decimal degrees of the report.
 *          lon: The longitude in decimal degrees of the report.
 *           db: The average level of noise.
 *    timestamp: The unix timestamp (in seconds) of the report.
 *     duration: The duration of the sampling (in seconds).
 */
- (NSURLRequest *)requestForFetchingNoiseReportsInMapRect:(MKMapRect)mapRect;

/*
 *  requestForAssigningTags:toNoise:
 *  
 *  Discussion:
 *    Returns a HTTP request object that can be used to set the specified tags
 *    to an  already reported noise (i.e. a noise with an identifier).
 *    The server must return a JSON response with a status field
 *    that indicates whether the request was successfully handled. Status codes are:
 *
 *       0: The request was succesfully handled.
 *     100: The server could not read the JSON object you provided.
 *     101: The request has an incorrect signature.
 *     102: The request was already sent to the server (duplicate).
 */
- (NSURLRequest *)requestForAssigningTags:(NSArray *)tags toNoise:(WTNoise *)noise;

@end
