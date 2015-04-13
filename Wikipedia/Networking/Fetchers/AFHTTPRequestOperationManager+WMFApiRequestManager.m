//
//  AFHTTPRequestOperationManager+WMFApiRequestManager.m
//  Wikipedia
//
//  Created by Brian Gerstle on 4/13/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "AFHTTPRequestOperationManager+WMFApiRequestManager.h"
#import "AFHTTPRequestOperationManager+WMFConfig.h"
#import "WMFApiRequestSerializer.h"

@implementation AFHTTPRequestOperationManager (WMFApiRequestManager)

+ (instancetype)wmf_apiRequestManager {
    return [self wmf_apiRequestManagerWithRequestSerializer:[WMFApiRequestSerializer serializer]
                                        responseSerializers:@[[AFJSONResponseSerializer serializerWithReadingOptions:0]]];
}

+ (instancetype)wmf_apiRequestManagerWithRequestSerializer:(AFHTTPRequestSerializer*)requestSerializer
                                       responseSerializers:(NSArray*)responseSerializers {
    NSParameterAssert(requestSerializer);
    NSParameterAssert(responseSerializers.count > 0);

    AFHTTPRequestOperationManager* manager = [self wmf_createDefaultManager];

    manager.requestSerializer = requestSerializer;

    if (responseSerializers.count > 1) {
        manager.responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:responseSerializers];
    } else {
        manager.responseSerializer = responseSerializers.firstObject;
    }

    return manager;
}

@end
