//
//  WMFArticlePreviewInteractionHandler.h
//  Wikipedia
//
//  Created by Brian Gerstle on 4/14/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMFArticlePreviewController.h"

@class MWKTitle;
@class MWKArticlePreview;

@interface WMFArticlePreviewInteractionHandler : NSObject
@property (nonatomic, weak) id<WMFArticlePreviewControllerDelegate> delegate;
@property (nonatomic, strong, readonly) MWKTitle* title;
@property (nonatomic, strong, readonly) MWKArticlePreview* preview;

- (instancetype)initWithPreview:(MWKArticlePreview*)preview
                       delegate:(id<WMFArticlePreviewControllerDelegate>)delegate
                          title:(MWKTitle*)title;

- (void)show;

@end