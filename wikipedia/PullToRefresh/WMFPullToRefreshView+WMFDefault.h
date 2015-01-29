
#import "WMFPullToRefreshView.h"
#import "WMFPullToRefreshContentView.h"

@interface WMFPullToRefreshView (WMFDefault)

+ (WMFPullToRefreshView*)defaultIndeterminateProgressViewWithScrollView:(UIScrollView *)scrollView delegate:(id<WMFPullToRefreshViewDelegate>)delegate;

+ (WMFPullToRefreshView*)defaultDeterminateProgressViewWithScrollView:(UIScrollView *)scrollView delegate:(id<WMFPullToRefreshViewDelegate>)delegate;

/**
 *  Convienence - Returns the contentView casts to WMFPullToRefreshContentView (or nil if it is not of that class)
 *
 *  @return the contentView
 */
- (WMFPullToRefreshContentView*)pullToRefreshContentView;

@end
