//
//  NSData+Base64.h
//  WideNoise
//
//  Created by Emilio Pavia on 30/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Base64Encoding)

+ (NSData *)dataWithBase64EncodedString:(NSString *)encodedString;
- (NSString *)base64Encoding;

@end
