

#import "WMFPullToRefreshView+WMFDefault.h"
#import "WMFPullToRefreshContentView.h"
#import <Masonry/Masonry.h>
#import "Defines.h"

@implementation WMFPullToRefreshView (WMFDefault)

+ (WMFPullToRefreshView*)defaultIndeterminateProgressViewWithScrollView:(UIScrollView *)scrollView delegate:(id<WMFPullToRefreshViewDelegate>)delegate{
    
    WMFPullToRefreshView* pullToRefresh = [[WMFPullToRefreshView alloc] initWithScrollView:scrollView delegate:delegate];
    [pullToRefresh setContentView:[[WMFPullToRefreshContentView alloc] initWithFrame:CGRectZero type:WMFPullToRefreshProgressTypeIndeterminate]];
    
    pullToRefresh.expandedHeight = 85.0 * MENUS_SCALE_MULTIPLIER;
    pullToRefresh.compactExpandedHeight = 55.0 * MENUS_SCALE_MULTIPLIER;
    pullToRefresh.pullStyle = WMFPullToRefreshPullStyleDistance;
    
    [pullToRefresh.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(pullToRefresh);
    }];
    
    return pullToRefresh;
}

+ (WMFPullToRefreshView*)defaultDeterminateProgressViewWithScrollView:(UIScrollView *)scrollView delegate:(id<WMFPullToRefreshViewDelegate>)delegate{
    
    WMFPullToRefreshView* pullToRefresh = [[WMFPullToRefreshView alloc] initWithScrollView:scrollView delegate:delegate];
    [pullToRefresh setContentView:[[WMFPullToRefreshContentView alloc] initWithFrame:CGRectZero type:WMFPullToRefreshProgressTypeDeterminate]];
    
    pullToRefresh.expandedHeight = 85.0 * MENUS_SCALE_MULTIPLIER;
    pullToRefresh.compactExpandedHeight = 55.0 * MENUS_SCALE_MULTIPLIER;
    pullToRefresh.pullStyle = WMFPullToRefreshPullStyleDistance;
    pullToRefresh.viewStyle = WMFPullToRefreshViewStyleStatic;
    
    [pullToRefresh.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(pullToRefresh);
    }];
    
    return pullToRefresh;
}

- (WMFPullToRefreshContentView*)pullToRefreshContentView{
    
    if(![self.contentView isKindOfClass:[WMFPullToRefreshContentView class]])
        return nil;
    
    return (WMFPullToRefreshContentView*)[self contentView];
}



@end
