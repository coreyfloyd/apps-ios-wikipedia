//
//  WMFArticlePreviewRequestTests.m
//  Wikipedia
//
//  Created by Brian Gerstle on 4/14/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AFHTTPRequestOperationManager+WMFApiRequestManager.h"
#import "WMFNetworkUtilities.h"
#import "WMFApiRequestParameters+ArticlePreview.h"

// set default timeout to 5s (since we're doing network I/O to get fixture data)
#define WMFDefaultExpectationTimeout 5
#import "WMFAsyncTestCase.h"

@interface WMFArticlePreviewRequestTests : XCTestCase
@property AFHTTPRequestOperationManager* manager;
@end

@implementation WMFArticlePreviewRequestTests

- (void)setUp {
    [super setUp];
    self.manager = [AFHTTPRequestOperationManager wmf_apiRequestManager];
}

- (void)testExample {
    WMFApiRequestParameters* articlePreviewRequestParams =
        [WMFApiRequestParameters articlePreviewParametersForTitle:@"Taiko"];

    XCTestExpectation* requestExpectation = [self expectationWithDescription:@"GET"];
    [self.manager GET:WMFBaseApiURL(@"en", @"wikipedia.org").absoluteString
           parameters:[articlePreviewRequestParams httpQueryParameterDictionary]
              success:^(AFHTTPRequestOperation* response, id json) {
        NSLog(@"Success! %@", json);
        [requestExpectation fulfill];
    }
              failure:^(AFHTTPRequestOperation* response, NSError* error) {
        NSLog(@"Failure! %@", error);
        [requestExpectation fulfill];
    }];

    WaitForExpectations();
}

@end
