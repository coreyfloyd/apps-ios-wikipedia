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
#import <BlocksKit/BlocksKit.h>
#import "WMFArticlePreviewInteractionHandler.h"
#import "AFHTTPRequestOperationManager+UniqueRequests.h"

@interface WMFArticlePreviewController ()
<UIAlertViewDelegate>
@property (nonatomic, copy, readonly) AFHTTPRequestOperationManager* requestManager;
@property (nonatomic, strong) WMFArticlePreviewInteractionHandler* interactionHandler;
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

- (void)showPreviewForPage:(MWKTitle*)pageTitle {
#warning TODO: cache model objects? JSON is supposedly already cached by the shared NSURLCache
    WMFApiRequestParameters* requestForPreview =
        [WMFApiRequestParameters articlePreviewParametersForTitle:pageTitle.prefixedText];

    __weak __typeof__(self) weakSelf = self;
    [self.requestManager
     wmf_idempotentGET:[[SessionSingleton sharedInstance] urlForLanguage:pageTitle.site.language].absoluteString
            parameters:[requestForPreview  httpQueryParameterDictionary]
               success:^(AFHTTPRequestOperation* response, MWKArticlePreview* articlePreview) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showPreviewWithData:articlePreview forTitle:pageTitle];
        });
    }
               failure:^(AFHTTPRequestOperation* response, NSError* error) {
        if (![error wmf_isCancelledCocoaError]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.delegate previewController:weakSelf failedToPreviewTitle:pageTitle error:error];
            });
        }
    }];
}

- (void)showPreviewWithData:(MWKArticlePreview*)previewData forTitle:(MWKTitle*)title {
    NSParameterAssert([NSThread isMainThread]);
    self.interactionHandler = [[WMFArticlePreviewInteractionHandler alloc] initWithPreview:previewData
                                                                                  delegate:self.delegate
                                                                                     title:title];
    [self.interactionHandler show];
}

@end
