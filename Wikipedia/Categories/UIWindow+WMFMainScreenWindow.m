//
//  UIWindow+WMFMainScreenWindow.m
//  Wikipedia
//
//  Created by Brian Gerstle on 3/24/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "UIWindow+WMFMainScreenWindow.h"
#import <Tweaks/FBTweakShakeWindow.h>

@implementation UIWindow (WMFMainScreenWindow)

+ (instancetype)wmf_newWithMainScreenBounds {
    
    return [[FBTweakShakeWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

@end
