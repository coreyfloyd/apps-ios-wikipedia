
#import "UIViewController+WMFCardPresenting.h"
#import "WMFCardHelpers.h"
#import <BlocksKit/BlocksKit.h>
#import "WMFCardViewController.h"
#import "NBSlideUpView.h"


#pragma mark - Accessors

@implementation UIViewController (WMFAccessors)

static NSString * kWMFCardViewController = @"kWMFCardViewController";

- (void)setCardController:(WMFCardViewController*)controller {
    [self bk_associateValue:controller withKey:(__bridge const void*)(kWMFCardViewController)];
}

- (WMFCardViewController*)cardController {
    return [self bk_associatedValueForKey:(__bridge const void*)(kWMFCardViewController)];
}

static NSString* kWMFSlideUpViewKey = @"kWMFSlideUpViewKey";

- (void)setSlideUpView:(NBSlideUpView*)slideupView {
    [self bk_associateValue:slideupView withKey:(__bridge const void*)(kWMFSlideUpViewKey)];
}

- (NBSlideUpView*)slideUpView {
    return [self bk_associatedValueForKey:(__bridge const void*)(kWMFSlideUpViewKey)];
}

static NSString* kWMFCompletionBlockKey = @"kWMFCompletionBlockKey";

- (void)setTapHandler:(dispatch_block_t)completion {
    [self bk_associateValue:completion withKey:(__bridge const void*)(kWMFCompletionBlockKey)];
}

- (dispatch_block_t)tapHandler {
    return [self bk_associatedValueForKey:(__bridge const void*)(kWMFCompletionBlockKey)];
}

@end



#pragma mark - NBSlideUpViewDelegate

@interface UIViewController (NBSlideUpViewDelegate)<NBSlideUpViewDelegate>

@end

@implementation UIViewController (NBSlideUpViewDelegate)


- (void)slideUpViewDidAnimateOut:(UIView*)slideUpView {
    if ([self cardController]) {
        [[self cardController] willMoveToParentViewController:nil];
        [[self cardController] removeFromParentViewController];
        [[self cardController].view removeFromSuperview];
        [self setCardController:nil];
    }

    if ([self slideUpView]) {
        [[self slideUpView] removeFromSuperview];
        [self setSlideUpView:nil];
    }
}

- (void)slideUpViewDidAnimateIn:(UIView*)slideUpView {
    [[self cardController] didMoveToParentViewController:self];
}

@end


#pragma mark - Presentation

@implementation UIViewController (WMFCardPresenting)

static CGFloat kWMFInterAnimationPause = 0.1;

- (void)presentCardForArticleWithTitle:(MWKTitle*)title animated:(BOOL)animated tapHandler:(dispatch_block_t)tapHandler {
    if ([self slideUpView]) {
        [[self slideUpView] animateOut];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(([[self slideUpView] animateInOutTime] + kWMFInterAnimationPause) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self presentCardForArticleWithTitle:title animated:animated tapHandler:tapHandler];
        });

        return;
    }

    [self setTapHandler:tapHandler];

    NBSlideUpView* slideUp = [[NBSlideUpView alloc] init];
    slideUp.viewablePixels = cardPopupHeight();
    slideUp.delegate       = self;
    [self setSlideUpView:slideUp];

    WMFCardViewController* vc = [WMFCardViewController cardViewControllerWithType:cardPopupType() pageTitle:title];
    [self setCardController:vc];
    [self addChildViewController:vc];

    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapWithGesture:)];
    [vc.view addGestureRecognizer:tap];

    slideUp.contentView = vc.view;

    [self.view addSubview:slideUp];

    [slideUp animateIn];
}

- (void)dismissCardAnimated:(BOOL)animated {
    if (!animated) {
        [self slideUpView].animateInOutTime = 0.0;
    } else {
        [self slideUpView].animateInOutTime = cardAnimationDuration();
    }

    [[self slideUpView] animateOut];
}

- (void)didTapWithGesture:(UITapGestureRecognizer*)tap {
    [self dismissCardAnimated:YES];

    if ([self tapHandler]) {
        [self tapHandler]();
    }
}

@end
