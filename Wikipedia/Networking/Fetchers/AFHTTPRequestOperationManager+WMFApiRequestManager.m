//
//  AFHTTPRequestOperationManager+WMFApiRequestManager.m
//  Wikipedia
//
//  Created by Brian Gerstle on 4/13/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "AFHTTPRequestOperationManager+WMFApiRequestManager.h"
#import "AFHTTPRequestOperationManager+WMFConfig.h"
#import "WMFJSONResponseSerializer.h"

@implementation AFHTTPRequestOperationManager (WMFApiRequestManager)

/// @return A request operation manager configured with WMF API request & response serializers.
+ (instancetype)wmf_apiRequestManager {
    return [self wmf_apiRequestManagerWithResponseSerializers:@[[WMFJSONResponseSerializer serializer]]];
}

/// @return A request operation manager with a WMF API request serializer and the given response serializers.
/// This can be used to allow one manager to handle WMF API and image data responses.
+ (instancetype)wmf_apiRequestManagerWithResponseSerializers:(NSArray*)responseSerializers {
    NSParameterAssert(responseSerializers.count > 0);

    AFHTTPRequestOperationManager* manager = [self wmf_createDefaultManager];

    if (responseSerializers.count > 1) {
        manager.responseSerializer =
            [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:responseSerializers];
    } else {
        manager.responseSerializer = responseSerializers.firstObject;
    }

    return manager;
}

@end
