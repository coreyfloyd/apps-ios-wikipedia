//
//  UIView+SnapShot.m
//  playQ
//
//  Created by Corey Floyd on 8/29/13.
//  Copyright (c) 2013 Flying Jalapeno. All rights reserved.
//

#import "UIView+SnapShot.h"

@implementation UIView (SnapShot)

- (UIImage*)snapshotOfContents {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);

    if ([self isKindOfClass:[UIScrollView class]]) {
        [self drawViewHierarchyInRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) afterScreenUpdates:YES];
    } else {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    }

    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
