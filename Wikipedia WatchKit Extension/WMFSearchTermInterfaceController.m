//
//  WMFSearchTermInterfaceController.m
//  Wikipedia
//
//  Created by Corey Floyd on 5/23/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "WMFSearchTermInterfaceController.h"
#import "WMFWatchSearchResultsRow.h"

@interface WMFSearchTermInterfaceController ()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *searchTermLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceTable *resultsTable;

@end

@implementation WMFSearchTermInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self.searchTermLabel setText:context];
    
    [WKInterfaceController openParentApplication:@{@"searchTerm":context} reply:^(NSDictionary *replyInfo, NSError *error) {
        
        NSArray* results = replyInfo[@"searchResults"];
        
        [self.resultsTable setNumberOfRows:(NSInteger)[results count] withRowType:@"SearchRow"];
        
        [results enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
            
            WMFWatchSearchResultsRow* row = [self.resultsTable rowControllerAtIndex:idx];
            [row.resultTitleLabel setText:obj[@"title"]];
            
        }];
        
        
        
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



