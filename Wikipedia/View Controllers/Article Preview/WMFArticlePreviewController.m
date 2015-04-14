//
//  WMFArticlePreviewController.m
//  Wikipedia
//
//  Created by Brian Gerstle on 4/14/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "WMFArticlePreviewController.h"
#import "AFHTTPRequestOperationManager+WMFApiRequestManager.h"
#import "MWKArticlePreviewResponseSerializer.h"
#import "WMFNetworkUtilities.h"
#import "SessionSingleton.h"
#import "WMFApiRequestParameters+ArticlePreview.h"
#import "MWKTitle.h"
#import "MWKArticlePreview.h"

@interface WMFArticlePreviewController ()
@property (nonatomic, copy, readonly) AFHTTPRequestOperationManager* requestManager;
@end

@implementation WMFArticlePreviewController

- (instancetype)init {
    AFHTTPRequestOperationManager* defaultRequestManager =
        [AFHTTPRequestOperationManager wmf_apiRequestManagerWithResponseSerializers:
         @[[MWKArticlePreviewResponseSerializer serializer]]];
    return [self initWithRequestManager:defaultRequestManager];
}

- (instancetype)initWithRequestManager:(AFHTTPRequestOperationManager*)requestManager {
    self = [super init];
    if (self) {
        _requestManager = [requestManager copy];
    }
    return self;
}

- (void)showPreviewForPage:(MWKTitle*)pageTitle
          openPageCallback:(WMFArticlePreviewOpenCallback)openPageCallback
                     error:(WMFArticlePreviewErrorCallback)errorCallback {
    WMFApiRequestParameters* requestForPreview =
        [WMFApiRequestParameters articlePreviewParametersForTitle:pageTitle.prefixedText];

    __weak __typeof__(self) weakSelf = self;
#warning TODO: keep the request around so it can be cancelled in the event of another request
#warning TODO: use idempotent get to prevent multiple in-flight requests for the same title
    //AFHTTPRequestOperation* request =
    [self.requestManager
     GET:[[SessionSingleton sharedInstance] urlForLanguage:pageTitle.site.language].absoluteString
     parameters:[requestForPreview  httpQueryParameterDictionary]
        success:^(AFHTTPRequestOperation* response, MWKArticlePreview* articlePreview) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showPopupWithData:articlePreview];
        });
    }
        failure:^(AFHTTPRequestOperation* response, NSError* error) {
        if (errorCallback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorCallback(pageTitle, error);
            });
        }
    }];
}

- (void)dismissPreview {
    // dismiss...
}

#pragma mark - Private methods

- (void)showPopupWithData:(MWKArticlePreview*)previewData {
    NSParameterAssert([NSThread isMainThread]);
    NSLog(@"Showing popup for article preview %@", previewData);
}

@end
