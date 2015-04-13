//
//  AFHTTPRequestOperationManager+WMFApiRequestManager.h
//  Wikipedia
//
//  Created by Brian Gerstle on 4/13/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface AFHTTPRequestOperationManager (WMFApiRequestManager)

+ (instancetype)wmf_apiRequestManager;

+ (instancetype)wmf_apiRequestManagerWithRequestSerializer:(AFHTTPRequestSerializer*)requestSerializers
                                       responseSerializers:(NSArray*)responseSerializers;



@end
