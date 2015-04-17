//
//  AFHTTPRequestOperationManager+WMFApiRequestManager.h
//  Wikipedia
//
//  Created by Brian Gerstle on 4/13/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface AFHTTPRequestOperationManager (WMFApiRequestManager)

/// @return A request operation manager configured with WMF API request & response serializers.
+ (instancetype)wmf_apiRequestManager;

/// @return A request operation manager with a WMF API request serializer and the given response serializers.
/// This can be used to allow one manager to handle WMF API and image data responses.
+ (instancetype)wmf_apiRequestManagerWithResponseSerializers:(NSArray*)responseSerializers;

@end
