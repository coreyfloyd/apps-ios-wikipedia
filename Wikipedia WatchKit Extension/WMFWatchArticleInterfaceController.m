//
//  WMFWatchArticleInterfaceController.m
//  Wikipedia
//
//  Created by Corey Floyd on 5/23/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "WMFWatchArticleInterfaceController.h"

@interface WMFWatchArticleInterfaceController ()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *textLabel;
- (IBAction)saveArticle;
- (IBAction)openOnPhone;

@end

@implementation WMFWatchArticleInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    NSDictionary* dict = context;

    [self.titleLabel setText:dict[@"title"]];
    [self.textLabel setText:dict[@"description"]];
     
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)saveArticle {
}

- (IBAction)openOnPhone {
    
}
@end



