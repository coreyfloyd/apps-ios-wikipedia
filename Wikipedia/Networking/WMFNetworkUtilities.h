//
//  WMFNetworkUtilities.h
//  Wikipedia
//
//  Created by Brian Gerstle on 2/5/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

/// @name Constants

extern NSString* const WMFNetworkingErrorDomain;

typedef NS_ENUM (NSInteger, WMFNetworkingError) {
    WMFNetworkingError_APIError
};


/// @name Functions

/**
 * Take an array of strings and concatenate them with "|" as a delimiter.
 * @return A string of the concatenated elements, or an empty string if @c props is empty or @c nil.
 */
extern NSString* WMFJoinedPropertyParameters(NSArray* props);

extern NSError* WMFErrorForApiErrorObject(NSDictionary* apiError);

/**
 * Construct a base API URL.
 * @param languageCode  A language code, e.g. "en".
 * @param siteDomain    A site domain, e.g. "wikipedia.org".
 * @return A URL which points to the API endpoint for the given mediawiki instance.
 */
extern NSURL* WMFBaseApiURL(NSString* languageCode, NSString* siteDomain);

#warning HAX: workaround for back-end JSON serialization bug which returns empty objects as arrays
/// @return A dictionary if `object` is a non-empty dictionary, otherwise `nil`.
inline static NSDictionary* WMFNonEmptyDictionary(id object) {
    return ([object isKindOfClass:[NSDictionary class]] && [object count] > 0) ? object : nil;
}

@interface NSDictionary (WMFNonEmptyDictForKey)

- (id)wmf_nonEmptyDictionaryForKey:(id<NSCopying>)key;

@end