//
//  WMFApiRequestParameters+ArticlePreview.h
//  Wikipedia
//
//  Created by Brian Gerstle on 4/14/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "WMFApiRequestParameters.h"

@interface WMFApiRequestParameters (ArticlePreview)

+ (instancetype)articlePreviewParametersForTitle:(NSString*)title;

+ (instancetype)articlePreviewParametersWithTitles:(NSArray*)titles thumbSize:(NSUInteger)thumbSize;

@end
