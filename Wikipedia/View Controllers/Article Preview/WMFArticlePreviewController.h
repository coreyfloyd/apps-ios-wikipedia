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

@class WMFArticlePreviewController;
@protocol WMFArticlePreviewControllerDelegate <NSObject>

- (void)openPageForTitle:(MWKTitle*)title;

- (void)previewController:(WMFArticlePreviewController*)controller
     failedToPreviewTitle:(MWKTitle*)title
                    error:(NSError*)error;

@end

/**
 * Controller (perhaps a view controller eventually) which manages the display of a preview for a given article.
 *
 * There might be different situations in which article previews are rendered, so we should probably separate any
 * modal-popover-specific concersn from fetching, loading, etc.
 */
@interface WMFArticlePreviewController : NSObject

@property (nonatomic, weak) id<WMFArticlePreviewControllerDelegate> delegate;

/// Designated initializer, only exposed for testing.
- (instancetype)initWithRequestManager:(AFHTTPRequestOperationManager*)requestManager;

/// Shows a preview for the article specified by `pageTitle`.
- (void)showPreviewForPage:(MWKTitle*)pageTitle;

@end
