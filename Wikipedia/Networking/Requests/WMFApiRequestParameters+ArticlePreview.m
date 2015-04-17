//
//  WMFApiRequestParameters+ArticlePreview.m
//  Wikipedia
//
//  Created by Brian Gerstle on 4/14/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "WMFApiRequestParameters+ArticlePreview.h"

@implementation WMFApiRequestParameters (ArticlePreview)

+ (instancetype)articlePreviewParametersForTitle:(NSString*)title {
    return [self articlePreviewParametersWithTitles:@[title] thumbSize:640];
}

+ (instancetype)articlePreviewParametersWithTitles:(NSArray*)titles thumbSize:(NSUInteger)thumbSize {
    return [WMFApiRequestParameters jsonQueryWithParameters:@{
                @"titles": titles,
                @"prop": @[@"extracts", @"pageimages", @"pageterms"],
                @"redirects": @"true",
                @"exsentences": @"2",
                @"explaintext": @"true",
                @"piprop": @"thumbnail",
                @"pithumbsize": @(thumbSize).stringValue,
                @"wbptterms": @"description"
            }];
}

@end
