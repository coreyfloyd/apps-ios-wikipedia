//
//  WMFNetworkUtilities.m
//  Wikipedia
//
//  Created by Brian Gerstle on 2/5/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "WMFNetworkUtilities.h"
#import "NSMutableDictionary+WMFMaybeSet.h"
#import "NSString+WMFHTMLParsing.h"

NSString* const WMFNetworkingErrorDomain = @"WMFNetworkingErrorDomain";

NSString* WMFJoinedPropertyParameters(NSArray* props){
    return [props ? : @[] componentsJoinedByString:@"|"];
}

NSError* WMFErrorForApiErrorObject(NSDictionary* apiError){
    if (!apiError) {
        return nil;
    }
    // build the dictionary this way to avoid early nil termination caused by missing keys in the error obj
    NSMutableDictionary* userInfoBuilder = [NSMutableDictionary dictionaryWithCapacity:3];
    void (^ maybeMapApiToUserInfo)(NSString*, NSString*) = ^(NSString* userInfoKey, NSString* apiErrorKey) {
        [userInfoBuilder wmf_maybeSetObject:apiError[apiErrorKey] forKey:userInfoKey];
    };
    maybeMapApiToUserInfo(NSLocalizedDescriptionKey, @"code");
    maybeMapApiToUserInfo(NSLocalizedFailureReasonErrorKey, @"info");
    maybeMapApiToUserInfo(NSLocalizedRecoverySuggestionErrorKey, @"*");
    return [NSError errorWithDomain:WMFNetworkingErrorDomain code:WMFNetworkingError_APIError userInfo:userInfoBuilder];
}

extern NSURL* WMFBaseApiURL(NSString* languageCode, NSString* siteDomain) {
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@.%@/w/api.php", languageCode, siteDomain]];
}

NSString* WMFExtractTextFromHTML(NSString* htmlString) {
    return [[htmlString wmf_joinedHtmlTextNodes] wmf_getCollapsedWhitespaceStringAdjustedForTerminalPunctuation];
}

@implementation NSDictionary (WMFNonEmptyDictForKey)

- (id)wmf_nonEmptyDictionaryForKey:(id<NSCopying>)key {
    return WMFNonEmptyDictionary(self[key]);
}

@end

@implementation NSError (WMFIsCancelled)

- (BOOL)wmf_isCancelledCocoaError {
    return [self.domain isEqualToString:NSCocoaErrorDomain] && self.code == NSURLErrorCancelled;
}

@end
