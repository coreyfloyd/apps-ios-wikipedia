//
//  GlanceController.m
//  Wikipedia WatchKit Extension
//
//  Created by Corey Floyd on 5/23/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "GlanceController.h"


@interface GlanceController ()

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *snippetLabel;
@property (strong, nonatomic) NSString *snippet;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end


@implementation GlanceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [manager stopUpdatingLocation];
    CLLocation *location = locations.firstObject;
    CLLocationDegrees lat = location.coordinate.latitude;
    CLLocationDegrees lon = location.coordinate.longitude;
    
    [WKInterfaceController openParentApplication:@{@"request" : @"nearby", @"lat" : @(lat), @"lon" : @(lon)} reply:^(NSDictionary *replyInfo, NSError *error) {
        self.titleLabel.text = replyInfo[@"title"];
        self.descriptionLabel.text = [replyInfo[@"distance"] stringValue];
        NSDictionary *pages = replyInfo[@"searchResults"][0][@"query"][@"pages"];
        NSString *key = pages.allKeys.firstObject;
        self.snippet = pages[key][@"extract"];
        [self.snippetLabel setText:self.snippet];
    }];
}

@end



