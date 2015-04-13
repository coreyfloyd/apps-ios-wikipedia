//
//  WMFApiRequestSerializerTests.m
//  Wikipedia
//
//  Created by Brian Gerstle on 4/13/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Expecta/Expecta.h>
#import "WMFApiRequestSerializer.h"
#import "WMFNetworkUtilities.h"
#import <BlocksKit/BlocksKit.h>

@interface WMFApiRequestSerializerTests : XCTestCase

@end

@implementation WMFApiRequestSerializerTests

- (void)testQueryParameterProcessingOnlyProcessesArrays {
    NSDictionary* queryParams = @{@"foo": @"bar",
                                  @"biz": @0,
                                  @"baz": @[@"fuz", @"fuzzy"]};
    NSDictionary* result = WMFReplaceArraysWithJoinedApiParameters(queryParams);
    [queryParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSArray class]]) {
            expect(result[key]).to.equal(WMFJoinedPropertyParameters(obj));
        } else {
            expect(result[key]).to.equal(obj);
        }
    }];
    expect(result).to.haveCountOf(queryParams.count);
}

- (void)testDefaultParameterOverrides {
    NSDictionary* queryParams = @{@"foo": @"bar",
                                  @"biz": @"0",
                                  @"baz": @[@"fuz", @"fuzzy"]};
    NSDictionary* overriddenDefaults = WMFDefaultApiParametersWithOverrides(queryParams);
    [self verifyOverriddenDefaults:overriddenDefaults preservedEntriesOf:queryParams];
    NSDictionary* defaults = WMFDefaultApiParameters();
    expect([overriddenDefaults objectsForKeys:defaults.allKeys notFoundMarker:[NSNull null]])
    .to.equal(defaults.allValues);
}

- (void)testDefaultParameterOverridesWithContinue {
    NSDictionary* queryParams = @{@"foo": @"bar",
                                  @"biz": @"0",
                                  @"baz": @[@"fuz", @"fuzzy"],
                                  @"continue": @"some continue value"};
    NSDictionary* overriddenDefaults = WMFDefaultApiParametersWithOverrides(queryParams);
    [self verifyOverriddenDefaults:overriddenDefaults preservedEntriesOf:queryParams];
    expect(overriddenDefaults[@"rawcontinue"]).to.beNil();
    expect(overriddenDefaults).to.haveCountOf(queryParams.count);
}

- (void)testDefaultParameterOverridesWithRawContinue {
    NSDictionary* queryParams = @{@"foo": @"bar",
                                  @"biz": @"0",
                                  @"baz": @[@"fuz", @"fuzzy"],
                                  @"rawcontinue": @"some continue value"};
    NSDictionary* overriddenDefaults = WMFDefaultApiParametersWithOverrides(queryParams);
    [self verifyOverriddenDefaults:overriddenDefaults preservedEntriesOf:queryParams];
    expect(overriddenDefaults).to.haveCountOf(queryParams.count);
}

- (void)verifyOverriddenDefaults:(NSDictionary*)result preservedEntriesOf:(NSDictionary*)overrides {
    [overrides enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        expect(result[key]).to.equal(obj);
    }];
}

- (void)testApiRequestSerializerProcessesQueryParamsAndPassesToHTTP {
    NSDictionary* queryParams = @{@"foo": @"bar",
                                  @"biz": @"0",
                                  @"baz": @[@"fuz", @"fuzzy"]};
    NSString* method = @"GET";
    NSString* urlString = @"http://foo.org/bar";
    NSError* error;

    NSMutableDictionary* expectedQueryParams =
        [WMFDefaultApiParametersWithOverrides(
            WMFReplaceArraysWithJoinedApiParameters(queryParams)) mutableCopy];
    expectedQueryParams[@"format"] = @"json";
    expectedQueryParams[@"action"] = WMFStringFromApiAction(WMFApiActionQuery);

    WMFApiRequestParameters* apiParams = [WMFApiRequestParameters jsonQueryWithParameters:queryParams];
    expect([apiParams httpQueryParameterDictionary]).to.equal(expectedQueryParams);

    NSURLRequest* actualSerializedRequest = [[WMFApiRequestSerializer serializer]
                                             requestWithMethod:method
                                             URLString:urlString
                                             parameters:apiParams
                                             error:&error];
    expect(error).to.beNil();
    for (NSString* keyValuePair in [actualSerializedRequest.URL.query componentsSeparatedByString:@"&"]) {
        NSArray* components = [keyValuePair componentsSeparatedByString:@"="];
        NSString* key = components.firstObject;
        expect(key.length).to.beTruthy();
        NSString* expectedValue = expectedQueryParams[key];
        if (expectedValue.length) {
            // non-empty values are in the form "key=value"
            expect([components lastObject])
            .to.equal([expectedValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
        } else {
            // keys with empty values should be in the form: "key="
            expect(components.lastObject).to.equal(@"");
        }
    }
}

@end
