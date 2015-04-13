//
//  WMFApiRequestSerializer.m
//  Wikipedia
//
//  Created by Brian Gerstle on 4/13/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "WMFApiRequestSerializer.h"
#import <BlocksKit/BlocksKit.h>
#import "WMFNetworkUtilities.h"

NS_ASSUME_NONNULL_BEGIN

NSString* WMFStringFromApiAction(WMFApiAction action) {
    static NSDictionary* actionStrings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        actionStrings = @{@(WMFApiActionQuery): @"query"};
        NSCAssert(actionStrings.count == WMFCountOfApiActions,
                  @"WMFApiAction => NSString map is missing values! %@", actionStrings);
    });
    return actionStrings[@(action)];
}

NSDictionary* WMFDefaultApiParameters() {
    static NSDictionary* defaults;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaults = @{@"rawcontinue": @""};
    });
    return defaults;
}

NSDictionary* WMFDefaultApiParametersWithOverrides(NSDictionary* params) {
    NSMutableDictionary* queryParamsBuilder = [WMFDefaultApiParameters() mutableCopy];
    [queryParamsBuilder addEntriesFromDictionary:params];
    if (params[@"continue"] && !params[@"rawcontinue"]) {
        [queryParamsBuilder removeObjectForKey:@"rawcontinue"];
    }
    return [queryParamsBuilder copy];
}

NSDictionary* WMFReplaceArraysWithJoinedApiParameters(NSDictionary* params) {
    return [params bk_map:^id (NSString* key, id obj) {
        return [obj isKindOfClass:[NSArray class]] ? WMFJoinedPropertyParameters(obj) : obj;
    }];
}

@implementation WMFApiRequestParameters

- (instancetype)initWithFormat:(NSString*)format action:(WMFApiAction)action queryParameters:(NSDictionary*)params {
    self = [super init];
    if (self) {
        _format          = [format copy];
        _action          = action;
        _queryParameters = WMFDefaultApiParametersWithOverrides(params);
    }
    return self;
}

+ (instancetype)jsonQueryWithParameters:(NSDictionary*)params {
    return [[self alloc] initWithFormat:@"json" action:WMFApiActionQuery queryParameters:params];
}

- (NSDictionary*)httpQueryParameterDictionary {
    NSMutableDictionary* queryParameters =
        [WMFDefaultApiParametersWithOverrides(
             WMFReplaceArraysWithJoinedApiParameters(self.queryParameters)) mutableCopy];
    [queryParameters setObject:self.format forKey:@"format"];
    [queryParameters setObject:WMFStringFromApiAction(self.action) forKey:@"action"];
    return [queryParameters copy];
}

@end

@implementation WMFApiRequestSerializer

- (NSURLRequest*)requestBySerializingRequest:(NSURLRequest*)request
                              withParameters:(WMFApiRequestParameters*)parameters
                                       error:(NSError* __autoreleasing*)error {
    NSParameterAssert([parameters isKindOfClass:[WMFApiRequestParameters class]]);
    return [super requestBySerializingRequest:request
                               withParameters:[parameters httpQueryParameterDictionary]
                                        error:error];
}

@end

NS_ASSUME_NONNULL_END