//
//  NSString+HMAC.m
//  WideNoise
//
//  Created by Emilio Pavia on 30/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "NSString+HMAC.h"

#import <CommonCrypto/CommonHMAC.h>

#import "NSData+Base64.h"

@implementation NSString (HMAC)

- (NSString *)HMACUsingSHA256WithKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [self cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    
    NSString *hash = [[HMAC base64Encoding] retain];
    [HMAC release];
    
    return [hash autorelease];
}

@end
