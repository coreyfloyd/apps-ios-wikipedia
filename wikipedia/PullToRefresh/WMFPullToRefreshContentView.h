

#import "WMFPullToRefreshView.h"

typedef NS_ENUM(NSUInteger, WMFPullToRefreshProgressType){
    
    WMFPullToRefreshProgressTypeIndeterminate,
    WMFPullToRefreshProgressTypeDeterminate
};

@interface WMFPullToRefreshContentView : UIView<WMFPullToRefreshContentView>

- (instancetype)initWithFrame:(CGRect)frame type:(WMFPullToRefreshProgressType)type;

@property (weak, nonatomic) WMFPullToRefreshView* pullToRefreshView;

@property (assign, nonatomic, readonly) WMFPullToRefreshProgressType type;

@property (strong, nonatomic) NSString *refreshPromptString;
@property (strong, nonatomic) NSString *refreshReleaseString;
@property (strong, nonatomic) NSString *refreshRunningString;

/**
 *  Only valid for WMFPullToRefreshProgressTypeDeterminate
 */
- (void)setLoadingProgress:(float)progress animated:(BOOL)animated;

/**
 *  Execute a block when cancel button is tapped
 */
@property (copy, nonatomic) dispatch_block_t refreshCancelBlock;

@end
