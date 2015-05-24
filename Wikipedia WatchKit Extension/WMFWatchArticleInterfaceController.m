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
@property (strong, nonatomic) NSDictionary *passedInData;
@property (strong, nonatomic) NSString *snippet;

- (IBAction)saveArticle;
- (IBAction)openOnPhone;

@end

@implementation WMFWatchArticleInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self setTitle:@"X"];
    self.passedInData = context;

    [self.titleLabel setText:context[@"title"]];
    [self.textLabel setText:@""];

}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    if(!self.snippet)
        [WKInterfaceController openParentApplication:@{@"request" : @"snippet", @"pageTitle" : self.passedInData[@"title"]} reply:^(NSDictionary *replyInfo, NSError *error) {
            NSDictionary *pages = replyInfo[@"searchResults"][0][@"query"][@"pages"];
            NSString *key = pages.allKeys.firstObject;
            self.snippet = pages[key][@"extract"];
            [self.textLabel setText:self.snippet];
            NSLog(@"%@", self.snippet);
        }];
    else
        [self.textLabel setText:self.snippet];
    
    [self updateUserActivity:@"org.wikimedia.wikipedia.watchkitextension.page" userInfo:@{@"pageTitle" : self.passedInData[@"title"]} webpageURL:nil];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];

//    [self invalidateUserActivity];
}

- (IBAction)saveArticle {
}

- (IBAction)openOnPhone {
    
}
@end



