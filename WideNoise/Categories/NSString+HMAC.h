//
//  NSString+HMAC.h
//  WideNoise
//
//  Created by Emilio Pavia on 30/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HMAC)

- (NSString *)HMACUsingSHA256WithKey:(NSString *)key;

@end
