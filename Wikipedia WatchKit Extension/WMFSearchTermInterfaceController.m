//
//  WMFSearchTermInterfaceController.m
//  Wikipedia
//
//  Created by Corey Floyd on 5/23/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "WMFSearchTermInterfaceController.h"
#import "WMFWatchArticleInterfaceController.h"
@interface WMFSearchTermInterfaceController ()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *searchTermLabel;

@end

@implementation WMFSearchTermInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self.searchTermLabel setText:[NSString stringWithFormat:@"Searching for %@", context]];
    
    [WKInterfaceController openParentApplication:@{@"request" : @"search", @"searchTerm":context} reply:^(NSDictionary *replyInfo, NSError *error) {
        
        NSArray* results = replyInfo[@"searchResults"];
        
        NSMutableArray* names = [NSMutableArray new];
        
        [results enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
            
            [names addObject:@"WMFWatchArticleInterfaceController"];
        }];
        
        [self presentControllerWithNames:names contexts:results];

    }];
    
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



