//
//  NSData+Base64.m
//  WideNoise
//
//  Created by Emilio Pavia on 30/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "NSData+Base64.h"

static char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static char decodingTable[128];
static BOOL initialized = NO;

@implementation NSData (Base64)

+ (void)initBase64 {
    memset(decodingTable, 0, (sizeof(decodingTable)/sizeof(*(decodingTable))));
    for (NSInteger i=0; i<(sizeof(encodingTable)/sizeof(*(encodingTable))); i++) {
        decodingTable[encodingTable[i]] = i;
    }
}

- (NSString *)base64Encoding
{
    NSInteger length = self.length;
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    for (NSInteger i=0; i<length; i+=3) {
        NSInteger value = 0;
        for (NSInteger j=i; j<(i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & ((const uint8_t *)self.bytes)[j]);
            }
        }
        
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    encodingTable[(value >> 18) & 0x3F];
        output[index + 1] =                    encodingTable[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? encodingTable[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? encodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[[NSString alloc] initWithData:data
                                  encoding:NSASCIIStringEncoding] autorelease];
}

+ (NSData *)dataWithBase64EncodedString:(NSString *)encodedString 
{    
    if (!initialized) {
        initialized = YES;
        [self initBase64];
    }
    
    const char *string = [encodedString cStringUsingEncoding:NSASCIIStringEncoding];
    NSInteger inputLength = encodedString.length;
    
    if ((string == NULL) || (inputLength % 4 != 0)) {
        return nil;
    }
    
    while (inputLength > 0 && string[inputLength - 1] == '=') {
        inputLength--;
    }
    
    NSInteger outputLength = inputLength * 3 / 4;
    NSMutableData *data = [[NSMutableData dataWithLength:outputLength] retain];
    uint8_t *output = data.mutableBytes;
    
    NSInteger inputPoint = 0;
    NSInteger outputPoint = 0;
    while (inputPoint < inputLength) {
        char i0 = string[inputPoint++];
        char i1 = string[inputPoint++];
        char i2 = inputPoint < inputLength ? string[inputPoint++] : 'A'; /* 'A' will decode to \0 */
        char i3 = inputPoint < inputLength ? string[inputPoint++] : 'A';
        
        output[outputPoint++] = (decodingTable[i0] << 2) | (decodingTable[i1] >> 4);
        if (outputPoint < outputLength) {
            output[outputPoint++] = ((decodingTable[i1] & 0xf) << 4) | (decodingTable[i2] >> 2);
        }
        if (outputPoint < outputLength) {
            output[outputPoint++] = ((decodingTable[i2] & 0x3) << 6) | decodingTable[i3];
        }
    }
    
    return [data autorelease];
}

@end
