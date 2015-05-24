//
//  InterfaceController.m
//  Wikipedia WatchKit Extension
//
//  Created by Corey Floyd on 5/23/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()

@property (weak, nonatomic) IBOutlet WKInterfaceButton *searchButton;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *searchTermLabel;
@property (assign, nonatomic) BOOL searchLabelDirty;


- (IBAction)search;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (void)willActivate {
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)search {
    
<<<<<<< HEAD
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
=======
    [self presentTextInputControllerWithSuggestions:nil allowedInputMode:WKTextInputModePlain completion:^(NSArray *results) {
        
        NSString* searchTerm = [results firstObject];
        
        if(searchTerm){
            
            [self.searchTermLabel setText:[NSString stringWithFormat:@"Searching for %@…", searchTerm]];
            [self.searchButton setHidden:YES];
            
            self.searchLabelDirty = YES;

            [WKInterfaceController openParentApplication:@{@"searchTerm":searchTerm} reply:^(NSDictionary *replyInfo, NSError *error) {
                
                NSArray* results = replyInfo[@"searchResults"];
                
                if([results count] == 0){
                    
                    [self.searchTermLabel setText:@"No Results"];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.searchTermLabel setText:@"Tap to Search"];
                        [self.searchButton setHidden:NO];
                    });
                    
                }
                
                NSMutableArray* names = [NSMutableArray new];
                
                [results enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
                    
                    [names addObject:@"WMFWatchArticleInterfaceController"];
                }];
                
                [self presentControllerWithNames:names contexts:results];

                [self.searchTermLabel setText:@"Tap to Search"];
                [self.searchButton setHidden:NO];

                
            }];

            
            
        }
       
        
        
        
    }];
>>>>>>> 84ca477f6668e1a0c256192da781261006bd2ab6
}
@end



