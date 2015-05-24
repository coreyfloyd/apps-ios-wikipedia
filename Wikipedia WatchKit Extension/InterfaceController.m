//
//  InterfaceController.m
//  Wikipedia WatchKit Extension
//
//  Created by Corey Floyd on 5/23/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()
- (IBAction)search;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

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

- (IBAction)search {
    
//    [self presentTextInputControllerWithSuggestions:nil allowedInputMode:WKTextInputModePlain completion:^(NSArray *results) {
//        
//        NSString* searchTerm = [results firstObject];
//        
//        if(searchTerm){
//            
//            [self pushControllerWithName:@"WMFSearchTermInterfaceController" context:searchTerm];
//        }
//       
//        
//        
//        
//    }];
    [self pushControllerWithName:@"WMFSearchTermInterfaceController" context:@"Dog"];
}
@end



