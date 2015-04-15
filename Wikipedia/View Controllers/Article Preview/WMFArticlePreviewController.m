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
#import "AFHTTPRequestOperationManager+UniqueRequests.h"

static void* const WMFAssociatedPreviewTitleKey = (void*)"com.wikimedia.wikipedia.articlepreview.associatedtitle";

inline static void WMFSetAssociatedPreviewTitle(id obj, MWKTitle* title) {
    [obj bk_associateValue:title withKey:WMFAssociatedPreviewTitleKey];
}

inline static MWKTitle* WMFGetAssociatedPreviewTitle(id obj) {
    return [obj bk_associatedValueForKey:WMFAssociatedPreviewTitleKey];
}

@interface WMFArticlePreviewController ()
<UIAlertViewDelegate>
@property (nonatomic, copy, readonly) AFHTTPRequestOperationManager* requestManager;

/**
 * Current preview UI.
 * @note This has the `weak` ownership qualifier to ensure that the current preview is automatically `nil` when
 *       it has been dismissed.
 */
@property (nonatomic, weak) UIAlertView* preview;
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

- (BOOL)isPreviewingTitle:(MWKTitle*)title {
    return [title.prefixedText isEqualToString:[self.preview bk_associatedValueForKey:WMFAssociatedPreviewTitleKey]];
}

- (void)showPreviewForPage:(MWKTitle*)pageTitle {
    if ([self isPreviewingTitle:pageTitle]) {
        return;
    }

    WMFApiRequestParameters* requestForPreview =
        [WMFApiRequestParameters articlePreviewParametersForTitle:pageTitle.prefixedText];

    __weak __typeof__(self) weakSelf = self;
    [self.requestManager
     wmf_idempotentGET:[[SessionSingleton sharedInstance] urlForLanguage:pageTitle.site.language].absoluteString
            parameters:[requestForPreview  httpQueryParameterDictionary]
               success:^(AFHTTPRequestOperation* response, MWKArticlePreview* articlePreview) {
#warning TODO: cache model object. JSON is supposedly already cached by the shared NSURLCache
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
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:previewData.pageTitle
                                                        message:previewData.pageDescription
                                                       delegate:self
                                              cancelButtonTitle:@"Back"
                                              otherButtonTitles:@"Open", nil];
    [alertView show];
    // using associated objects to tie "current title" state to the transient alert view
    WMFSetAssociatedPreviewTitle(alertView, title);
    self.preview = alertView;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        MWKTitle* title = WMFGetAssociatedPreviewTitle(alertView);
        NSAssert(title, @"Title was never set for preview!");
        if (title) {
            [self.delegate openPageForTitle:title];
        }
    }
}

@end
