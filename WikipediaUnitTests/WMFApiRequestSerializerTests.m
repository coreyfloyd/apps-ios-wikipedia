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
#import "WMFApiRequestParameters.h"

@interface WMFApiRequestSerializerTests : XCTestCase

@end

@implementation WMFApiRequestSerializerTests

- (void)testApiRequestSerializerProcessesQueryParamsAndPassesToHTTP {
    NSDictionary* queryParams = @{@"foo": @"bar",
                                  @"biz": @"0",
                                  @"baz": @[@"fuz", @"fuzzy"]};
    NSString* method = @"GET";
    NSString* urlString = @"http://foo.org/bar";
    NSError* error;

    WMFApiRequestParameters* apiParams = [WMFApiRequestParameters jsonQueryWithParameters:queryParams];
    NSDictionary* expectedQueryParams = [apiParams httpQueryParameterDictionary];

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
