//
//  WMFApiRequestSerializer.m
//  Wikipedia
//
//  Created by Brian Gerstle on 4/13/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "WMFApiRequestSerializer.h"
#import "WMFApiRequestParameters.h"

NS_ASSUME_NONNULL_BEGIN

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