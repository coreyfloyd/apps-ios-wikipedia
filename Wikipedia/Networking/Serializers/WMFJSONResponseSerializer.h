//
//  WMFJSONResponseSerializer.h
//  Wikipedia
//
//  Created by Brian Gerstle on 4/14/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import <AFNetworking/AFURLResponseSerialization.h>

@interface WMFJSONResponseSerializer : AFJSONResponseSerializer

/**
 * Deserialize `json` into model objects.
 *
 * @param json A JSON object.
 *
 * @discussion
 * Subclasses can override this method instead of `responseObjectForResponse:data:error:` to conveniently deserialize
 * and return one or more custom model instead of the raw JSON. This method will only be called for a successful
 * response.
 *
 * @return Objects deserialized from the given JSON object.
 */
- (id)deserializeJSON:(id)json;

@end
