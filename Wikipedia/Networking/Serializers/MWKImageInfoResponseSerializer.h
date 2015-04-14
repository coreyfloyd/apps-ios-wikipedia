//
//  WMFImageMetadataSerializer.h
//  Wikipedia
//
//  Created by Brian Gerstle on 2/5/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "WMFJSONResponseSerializer.h"

@interface MWKImageInfoResponseSerializer : WMFJSONResponseSerializer

+ (NSArray*)requiredExtMetadataKeys;

@end
