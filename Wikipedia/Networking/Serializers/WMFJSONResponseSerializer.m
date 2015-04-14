//
//  WMFJSONResponseSerializer.m
//  Wikipedia
//
//  Created by Brian Gerstle on 4/14/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "WMFJSONResponseSerializer.h"
#import "WMFNetworkUtilities.h"

@implementation WMFJSONResponseSerializer

- (id)deserializeJSON:(id)json {
    return json;
}

- (id)responseObjectForResponse:(NSURLResponse*)response
                           data:(NSData*)data
                          error:(NSError* __autoreleasing*)error {
    NSDictionary* json = [super responseObjectForResponse:response data:data error:error];
    if (!json || *error) {
        return nil;
    }
    NSDictionary* apiError = json[@"error"];
    if (apiError) {
        if (error) {
            *error = WMFErrorForApiErrorObject(apiError);
        }
        return nil;
    }
    return [self deserializeJSON:json];
}

@end
