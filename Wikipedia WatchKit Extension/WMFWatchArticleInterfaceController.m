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
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *snippetLabel;
@property (strong, nonatomic) NSDictionary *passedInData;
@property (strong, nonatomic) NSString *snippet;

@property (strong, nonatomic)  NSString *articleTitle;

- (IBAction)saveArticle;
- (IBAction)openOnPhone;

@end

@implementation WMFWatchArticleInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self setTitle:@"Done"];
    NSDictionary* dict = context;
    self.passedInData = dict;
    
    self.articleTitle = dict[@"title"];
    [self.titleLabel setText:dict[@"title"]];
    [self.textLabel setText:dict[@"description"]];
    [self.snippetLabel setText:nil];

}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    if(!self.snippet)
        [WKInterfaceController openParentApplication:@{@"request" : @"snippet", @"pageTitle" : self.passedInData[@"title"]} reply:^(NSDictionary *replyInfo, NSError *error) {
            NSDictionary *pages = replyInfo[@"searchResults"][0][@"query"][@"pages"];
            NSString *key = pages.allKeys.firstObject;
            self.snippet = pages[key][@"extract"];
            [self.snippetLabel setText:self.snippet];
        }];
    else
        [self.snippetLabel setText:self.snippet];
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];

//    [self invalidateUserActivity];
}

- (IBAction)saveArticle {
    
    [WKInterfaceController openParentApplication:@{@"request":@"save", @"title":self.articleTitle} reply:^(NSDictionary *replyInfo, NSError *error) {
       
        [self presentControllerWithName:@"WMFSavedConfirmationInterfaceController" context:nil];
        
    }];
    
}

-(IBAction)openOnPhone {
    [self presentControllerWithName:@"OpenOniPhoneController" context:self.articleTitle];
}

@end



