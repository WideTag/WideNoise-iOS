//
//  NSURLConnection+Blocks.m
//  WideNoise
//
//  Created by Emilio Pavia on 24/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "NSURLConnection+Blocks.h"

@implementation NSURLConnection (Blocks)

+ (void)sendAsynchronousRequest:(NSURLRequest *)request 
                      onSuccess:(void(^)(NSData *, NSURLResponse *))successBlock
                      onFailure:(void(^)(NSData *, NSError *))failureBlock
{
    if (request == nil) {
        return;
    }
    dispatch_queue_t requestQueue = dispatch_queue_create("Request handler", NULL);
    dispatch_async(requestQueue, ^{
        NSURLResponse *response = nil;  
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                failureBlock(data, error);
            } else {  
                successBlock(data, response);  
            }  
        });
    });
    dispatch_release(requestQueue);
}

@end
