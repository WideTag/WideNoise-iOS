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
 *     101: The request was already sent to the server (duplicate).
 *     102: The request has an incorrect signature.
 */
- (NSURLRequest *)requestForReportingNoise:(WTNoise *)noise date:(NSDate *)date;

@end
