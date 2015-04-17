//
//  WMFImageMetadataSerializer.m
//  Wikipedia
//
//  Created by Brian Gerstle on 2/5/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "MWKImageInfoResponseSerializer.h"
#import "WMFNetworkUtilities.h"
#import "MWKImageInfo.h"
#import "NSString+WMFHTMLParsing.h"

/// Required extmetadata keys, don't forget to add new ones to +requiredExtMetadataKeys!
static NSString* const ExtMetadataImageDescriptionKey = @"ImageDescription";
static NSString* const ExtMetadataArtistKey           = @"Artist";
static NSString* const ExtMetadataLicenseUrlKey       = @"LicenseUrl";
static NSString* const ExtMetadataLicenseShortNameKey = @"LicenseShortName";
static NSString* const ExtMetadataLicenseKey          = @"License";

static CGSize MWKImageInfoSizeFromJSON(NSDictionary* json, NSString* widthKey, NSString* heightKey) {
    NSNumber* width  = json[widthKey];
    NSNumber* height = json[heightKey];
    if (width && height) {
        // both NSNumber & NSString respond to `floatValue`
        return CGSizeMake([width floatValue], [height floatValue]);
    } else {
        return CGSizeZero;
    }
}

@implementation MWKImageInfoResponseSerializer

+ (NSArray*)requiredExtMetadataKeys {
    return @[ExtMetadataLicenseKey,
             ExtMetadataLicenseUrlKey,
             ExtMetadataLicenseShortNameKey,
             ExtMetadataImageDescriptionKey,
             ExtMetadataArtistKey];
}

- (id)deserializeJSON:(id)json {
    NSDictionary* indexedImages =
        [[json wmf_nonEmptyDictionaryForKey:@"query"] wmf_nonEmptyDictionaryForKey:@"pages"];

    NSMutableArray* itemListBuilder = [NSMutableArray arrayWithCapacity:[[indexedImages allKeys] count]];

    [indexedImages enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* image, BOOL* stop) {
        NSDictionary* imageInfo = WMFNonEmptyDictionary([image[@"imageinfo"] firstObject]);
        NSDictionary* extMetadata = [imageInfo wmf_nonEmptyDictionaryForKey:@"extmetadata"];
        NSDictionary* licenseJSON = [extMetadata wmf_nonEmptyDictionaryForKey:ExtMetadataLicenseKey];

        MWKLicense* license =
            [[MWKLicense alloc] initWithCode:licenseJSON[@"value"]
                            shortDescription:licenseJSON[@"value"]
                                         URL:[NSURL URLWithString:licenseJSON[@"value"]]];

        NSString* imageDescription =
            [[[extMetadata wmf_nonEmptyDictionaryForKey:ExtMetadataImageDescriptionKey][@"value"]
              wmf_joinedHtmlTextNodes]
             wmf_getCollapsedWhitespaceStringAdjustedForTerminalPunctuation];

        NSString* owner =
            [[[extMetadata wmf_nonEmptyDictionaryForKey:ExtMetadataArtistKey][@"value"]
              wmf_joinedHtmlTextNodes]
             wmf_getCollapsedWhitespaceStringAdjustedForTerminalPunctuation];

        MWKImageInfo* item =
            [[MWKImageInfo alloc]
             initWithCanonicalPageTitle:image[@"title"]
                       canonicalFileURL:[NSURL URLWithString:imageInfo[@"url"]]
                       imageDescription:imageDescription
                                license:license
                            filePageURL:[NSURL URLWithString:imageInfo[@"descriptionurl"]]
                               imageURL:[NSURL URLWithString:imageInfo[@"url"]]
                          imageThumbURL:[NSURL URLWithString:imageInfo[@"thumburl"]]
                                  owner:owner
                              imageSize:MWKImageInfoSizeFromJSON(imageInfo, @"width", @"height")
                              thumbSize:MWKImageInfoSizeFromJSON(imageInfo, @"thumbwidth", @"thumbheight")];
        [itemListBuilder addObject:item];
    }];
    return itemListBuilder;
}

@end
