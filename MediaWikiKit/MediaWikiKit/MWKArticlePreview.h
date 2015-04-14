//
//  MWKArticlePreview.h
//  Wikipedia
//
//  Created by Brian Gerstle on 4/14/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MWKArticlePreview : NSObject

@property (nonatomic, readonly) NSInteger pageID;
@property (nonatomic, copy, readonly) NSString* pageTitle;
@property (nonatomic, copy, readonly) NSString* pageDescription;
@property (nonatomic, copy, readonly) NSString* pageSnippet;
@property (nonatomic, copy, readonly) NSString* thumbnailURL;
@property (nonatomic, readonly) CGSize thumbnailSize;

- (instancetype)initWithPageID:(NSInteger)pageID
                     pageTitle:(NSString*)pageTitle
               pageDescription:(NSString*)pageDescription
                   pageSnippet:(NSString*)pageSnippet
                  thumbnailURL:(NSString*)thumbnailURL
                 thumbnailSize:(CGSize)thumbnailSize;

@end
