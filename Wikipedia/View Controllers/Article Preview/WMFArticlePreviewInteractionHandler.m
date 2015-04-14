//
//  WMFArticlePreviewInteractionHandler.m
//  Wikipedia
//
//  Created by Brian Gerstle on 4/14/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "WMFArticlePreviewInteractionHandler.h"
#import "MWKTitle.h"
#import "MWKArticlePreview.h"

@interface WMFArticlePreviewInteractionHandler ()
@property (nonatomic, weak) UIAlertView* alertView;
@end

@implementation WMFArticlePreviewInteractionHandler

- (instancetype)initWithPreview:(MWKArticlePreview*)preview
                       delegate:(id<WMFArticlePreviewControllerDelegate>)delegate
                          title:(MWKTitle*)title {
    self = [super init];
    if (self) {
        _preview  = preview;
        _delegate = delegate;
        _title    = title;
    }
    return self;
}

- (void)show {
    UIAlertView* alertView =
        [[UIAlertView alloc] initWithTitle:self.preview.pageTitle
                                   message:self.preview.pageDescription
                                  delegate:self
                         cancelButtonTitle:@"Back"
                         otherButtonTitles:@"Open", nil];
    self.alertView = alertView;
    [self.alertView show];
}

- (void)dealloc {
    [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self.delegate openPageForTitle:self.title];
    }
    self.alertView = nil;
}

@end
