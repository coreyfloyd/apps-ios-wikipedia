//
//  WMFApiRequestSerializer.h
//  Wikipedia
//
//  Created by Brian Gerstle on 4/13/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import <AFNetworking/AFURLRequestSerialization.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSUInteger, WMFApiAction) {
    /// "query" action
    WMFApiActionQuery = 0,

    /// The count of all defined actions for this enum.
    /// @warning Not meant to be passed as an action value.
    WMFCountOfApiActions
};

@interface WMFApiRequestParameters : NSObject

/// Payload data format, defaults to JSON.
@property (nonatomic, readonly, copy) NSString* format;

@property (nonatomic, readonly) WMFApiAction action;

/// Additional query parameters.
/// @note Any `format` or `action` key/value pairs will be ignored, use the `format` and `action` properties instead.
@property (nonatomic, readonly, copy) NSDictionary* queryParameters;

/**
 * Create an instance with the `WMFApiActionQuery` action, JSON format, and specified API parameters.
 * @note If unspecified, a `rawcontinue` parameter will be added to suppress continuation warnings.
 */
+ (instancetype)jsonQueryWithParameters:(NSDictionary*)params;

/// Serialize the receiver into a dictionary which can be serialized into query parameters by AFNetworking.
- (NSDictionary*)httpQueryParameterDictionary;

@end

/// Serializes requests being sent to the MediaWiki API.
@interface WMFApiRequestSerializer : AFHTTPRequestSerializer

@end

///
/// @name Converters
///

/// Convert a `WMFApiAction` into its raw string value.
extern NSString* WMFStringFromApiAction(WMFApiAction action);

/// @return A dictionary containing default key/value pairs for API requests.
extern NSDictionary* WMFDefaultApiParameters();

/// @return A new dictionary which has the default values for API keys that aren't already present in `params`.
extern NSDictionary* WMFDefaultApiParametersWithOverrides(NSDictionary* params);

/// @return A dictionary with the array values in `param` mapped to a single "|" delimited string.
extern NSDictionary* WMFReplaceArraysWithJoinedApiParameters(NSDictionary* params);

NS_ASSUME_NONNULL_END