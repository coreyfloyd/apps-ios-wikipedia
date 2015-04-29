
#import <UIKit/UIKit.h>

@class MWKTitle;

@interface UIViewController (WMFCardPresenting)

- (void)presentCardForArticleWithTitle:(MWKTitle*)title animated:(BOOL)animated tapHandler:(dispatch_block_t)tapHandler;

- (void)dismissCardAnimated:(BOOL)animated;

@end
