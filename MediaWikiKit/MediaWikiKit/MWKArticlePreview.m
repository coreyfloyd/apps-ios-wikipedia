//
//  MWKArticlePreview.m
//  Wikipedia
//
//  Created by Brian Gerstle on 4/14/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "MWKArticlePreview.h"
#import "WikipediaAppUtils.h"

@implementation MWKArticlePreview

- (instancetype)initWithPageID:(NSInteger)pageID
                     pageTitle:(NSString*)pageTitle
               pageDescription:(NSString*)pageDescription
                   pageSnippet:(NSString*)pageSnippet
                  thumbnailURL:(NSString*)thumbnailURL
                 thumbnailSize:(CGSize)thumbnailSize {
    self = [super init];
    if (self) {
        _pageID          = pageID;
        _pageDescription = [pageDescription copy];
        _pageTitle       = [pageTitle copy];
        _pageSnippet     = [pageSnippet copy];
        _thumbnailURL    = [thumbnailURL copy];
        _thumbnailSize   = thumbnailSize;
    }
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"%@ {\n"
            "\t" "pageID: %ld, \n"
            "\t" "pageTitle: %@, \n"
            "\t" "pageDescription: %@, \n"
            "\t" "pageSnippet: %@, \n"
            "\t" "thumbnailURL: %@, \n"
            "\t" "thumbnailSize: %@ \n"
            "}\n",
            [super description],
            self.pageID,
            self.pageTitle,
            self.pageDescription,
            self.pageSnippet,
            self.thumbnailURL,
            NSStringFromCGSize(self.thumbnailSize)];
}

- (NSUInteger)hash {
    return self.pageID
           ^ CircularBitwiseRotation(self.pageTitle.hash, 1)
           ^ CircularBitwiseRotation(self.pageDescription.hash, 2)
           ^ CircularBitwiseRotation(self.pageSnippet.hash, 3)
           ^ CircularBitwiseRotation(self.thumbnailURL.hash, 4)
           ^ CircularBitwiseRotation(self.thumbnailSize.width, 5)
           ^ CircularBitwiseRotation(self.thumbnailSize.height, 6);
}

@end
