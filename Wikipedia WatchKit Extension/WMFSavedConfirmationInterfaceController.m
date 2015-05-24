//
//  WMFSavedConfirmationInterfaceController.m
//  Wikipedia
//
//  Created by Corey Floyd on 5/24/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "WMFSavedConfirmationInterfaceController.h"

@interface WMFSavedConfirmationInterfaceController ()

@end

@implementation WMFSavedConfirmationInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self setTitle:@"Done"];

    // Configure interface objects here.
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



