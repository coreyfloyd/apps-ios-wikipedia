
#import <UIKit/UIKit.h>

@class MWKTitle;

@interface UIViewController (WMFCardPresenting)

- (void)presentCardForArticleWithTitle:(MWKTitle*)title animated:(BOOL)animated completion:(dispatch_block_t)completion;

- (void)dismissCardAnimated:(BOOL)animated;

@end
