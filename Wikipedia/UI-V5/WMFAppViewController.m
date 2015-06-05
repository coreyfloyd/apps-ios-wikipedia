//
//  WMFAppViewController.m
//  Wikipedia
//
//  Created by Corey Floyd on 6/4/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "WMFAppViewController.h"
#import "WMFStyleManager.h"
#import "WMFSearchViewController.h"
#import "WMFArticleListCollectionViewController.h"
#import "DataMigrationProgressViewController.h"

NSString* const WMFDefaultStoryBoardName = @"iPhone_Root";

@implementation UIStoryboard (WMFDefaultStoryBoard)

+ (UIStoryboard*)wmf_defaultStoryBoard{
    
    return [UIStoryboard storyboardWithName:WMFDefaultStoryBoardName bundle:nil];
}

@end

@interface WMFAppViewController ()

@property (nonatomic, strong) IBOutlet UIView* splashView;

@end

@implementation WMFAppViewController

+ (WMFAppViewController*)initialAppViewControllerFromDefaultStoryBoard{
    
    return [[UIStoryboard wmf_defaultStoryBoard] instantiateInitialViewController];
}

- (void)launchAppInWindow:(UIWindow*)window{
    
    [window setRootViewController:self];
    [self showSplashView];
    
    [self runDataMigrationIfNeededWithCompletion:^{
        
        [self showMainUI];
    }];
}

- (void)resumeApp{
    
    //TODO: restore any UI, show Today
}


- (void)showSplashView{
    
    self.splashView.hidden = NO;
    self.splashView.layer.transform = CATransform3DIdentity;
    self.splashView.alpha = 1.0;
}

- (void)hideSplashViewAnimated:(BOOL)animated{
    
    NSTimeInterval duration = animated ? 0.3 : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        
        self.splashView.layer.transform = CATransform3DMakeScale(10.0f, 10.0f, 1.0f);
        self.splashView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        self.splashView.hidden = YES;
        self.splashView.layer.transform = CATransform3DIdentity;
    }];
}

- (BOOL)isShowingSplashView{
    
    return self.splashView.hidden == NO;
}

- (void)showMainUI{
    
    //TODO: tell embeded VCs to load their data
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Migration

- (void)runDataMigrationIfNeededWithCompletion:(dispatch_block_t)completion {
    
    DataMigrationProgressViewController* migrationVC = [[DataMigrationProgressViewController alloc] init];
    [migrationVC removeOldDataBackupIfNeeded];

    if (![migrationVC needsMigration]) {
        if(completion){
            completion();
        }
        return;
    }

    [self presentViewController:migrationVC animated:YES completion:^{
        
        [migrationVC runMigrationWithCompletion:^(BOOL migrationCompleted) {
            
            [migrationVC dismissViewControllerAnimated:YES completion:NULL];
            if(completion){
                completion();
            }
        }];
    }];
}

@end
