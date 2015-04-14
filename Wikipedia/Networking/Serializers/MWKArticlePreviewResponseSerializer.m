//
//  MWKArticlePreviewResponseSerializer.m
//  Wikipedia
//
//  Created by Brian Gerstle on 4/14/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "MWKArticlePreviewResponseSerializer.h"
#import "WMFNetworkUtilities.h"
#import "MWKArticlePreview.h"
#import "NSString+WMFHTMLParsing.h"

@implementation MWKArticlePreviewResponseSerializer

- (id)deserializeJSON:(id)json {
    NSDictionary* articlePreviewJSON =
        [[[[json wmf_nonEmptyDictionaryForKey:@"query"] wmf_nonEmptyDictionaryForKey:@"pages"] allValues] firstObject];

    NSDictionary* thumbnail = [articlePreviewJSON wmf_nonEmptyDictionaryForKey:@"thumbnail"];
    float thumbnailHeight   = [thumbnail[@"height"] floatValue];
    float thumbnailWidth    = [thumbnail[@"width"] floatValue];
    NSString* description   = [[articlePreviewJSON wmf_nonEmptyDictionaryForKey:@"terms"][@"description"] firstObject];
    description = [description wmf_stringByExtractingAndSanitizingHTML];

    return [[MWKArticlePreview alloc]
            initWithPageID:[articlePreviewJSON[@"pageid"] integerValue]
                  pageTitle:articlePreviewJSON[@"title"]
            pageDescription:description
                pageSnippet:[articlePreviewJSON[@"extract"] wmf_stringByExtractingAndSanitizingHTML]
               thumbnailURL:thumbnail[@"source"]
              thumbnailSize:CGSizeMake(thumbnailWidth, thumbnailHeight)];
}

@end
