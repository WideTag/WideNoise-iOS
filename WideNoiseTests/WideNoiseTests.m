//
//  WideNoiseTests.m
//  WideNoiseTests
//
//  Created by Emilio Pavia on 24/08/11.
//  Copyright 2011 WideTag, In. All rights reserved.
//

#import "WideNoiseTests.h"

#import "NSData+Base64.h"
#import "WTNoise.h"

@implementation WideNoiseTests

- (void)setUp
{
    [super setUp];
    
    noise = [[WTNoise alloc] init];
}

- (void)tearDown
{
    [noise release];
    
    [super tearDown];
}

- (void)testNoiseModel
{
    STAssertEquals([noise.samples count], (NSUInteger)0, @"Init condition failed!");
    
    [noise addSample:60];
    STAssertEquals([noise.samples count], (NSUInteger)1, @"Adding sample failed!");
    
    [noise addSample:-1];
    STAssertEquals([(NSNumber *)[noise.samples lastObject] floatValue], (float)0.0, @"Out of bounds level assignment failed!");
    
    [noise addSample:121];
    STAssertEquals([(NSNumber *)[noise.samples lastObject] floatValue], (float)120.0, @"Out of bounds level assignment failed!");
    
    STAssertEquals(noise.averageLevel, (float)60.0, @"Average level calculation failed!");
}

- (void)testBase64Encoder
{
    NSString *testString = @"This is a test for the NSData Base64 encoding/decoding";
    NSData *testData = [[NSData alloc] initWithBytes:[testString cStringUsingEncoding:NSUTF8StringEncoding] length:testString.length];
    
    NSData *decodedData = [NSData dataWithBase64EncodedString:[testData base64Encoding]];
    NSString *decodedString = [[NSString alloc] initWithBytes:decodedData.bytes length:decodedData.length encoding:NSUTF8StringEncoding];
    
    NSAssert([testString isEqualToString:decodedString], @"Base64 encoding test failed!");
    
    [decodedString release];
    [testData release];
}

@end
