//
//  NSURLConnection+Blocks.h
//  WideNoise
//
//  Created by Emilio Pavia on 24/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLConnection (Blocks)

+ (void)sendAsynchronousRequest:(NSURLRequest *)request 
                      onSuccess:(void(^)(NSData *, NSURLResponse *))successBlock
                      onFailure:(void(^)(NSData *, NSError *))failureBlock;

@end
