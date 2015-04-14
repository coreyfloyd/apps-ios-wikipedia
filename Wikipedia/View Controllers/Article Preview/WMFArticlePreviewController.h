//
//  WMFArticlePreviewController.h
//  Wikipedia
//
//  Created by Brian Gerstle on 4/14/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MWKTitle;
@class AFHTTPRequestOperationManager;

typedef void (^ WMFArticlePreviewOpenCallback)(MWKTitle* pageTitle);
typedef void (^ WMFArticlePreviewErrorCallback)(MWKTitle* pageTitle, NSError* error);

/**
 * Controller (perhaps a view controller eventually) which manages the display of a preview for a given article.
 *
 * There might be different situations in which article previews are rendered, so we should probably separate any
 * modal-popover-specific concersn from fetching, loading, etc.
 */
@interface WMFArticlePreviewController : NSObject

/// Designated initializer, only exposed for testing.
- (instancetype)initWithRequestManager:(AFHTTPRequestOperationManager*)requestManager;

/**
 * Shows a preview for an article, with capabilities to dismiss the preview and open the previewed page.
 * @param pageTitle The title of the page to preview.
 * @param openPage  Block which will be invoked when the user indicates they want to open the page being previewed.
 */
- (void)showPreviewForPage:(MWKTitle*)pageTitle
          openPageCallback:(WMFArticlePreviewOpenCallback)openPage
                     error:(WMFArticlePreviewErrorCallback)error;

// placeholder...
- (void)dismissPreview;

@end
