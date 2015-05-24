//
//  WMFOpenOniPhoneInterfaceController.m
//  Wikipedia
//
//  Created by Jason Ji on 5/24/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "WMFOpenOniPhoneInterfaceController.h"

@interface WMFOpenOniPhoneInterfaceController ()

@end

@implementation WMFOpenOniPhoneInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    [self updateUserActivity:@"org.wikimedia.wikipedia.watchkitextension.page" userInfo:@{@"pageTitle" : context} webpageURL:nil];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



