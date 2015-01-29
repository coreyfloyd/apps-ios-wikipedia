
#import "WMFPullToRefreshContentView.h"
#import "Defines.h"
#import "WikiGlyph_Chars.h"
#import "Masonry.h"
#import "WikipediaAppUtils.h"
#import "PaddedLabel.h"
#import "WMFProgressLineView.h"
#import "WMFBorderButton.h"

typedef NS_ENUM(NSUInteger, WMPullToRefreshIndeterminateProgressState){
    WMPullToRefreshIndeterminateProgressState0 = 0,
    WMPullToRefreshIndeterminateProgressState1,
    WMPullToRefreshIndeterminateProgressState2,
    WMPullToRefreshIndeterminateProgressState3
};

@interface WMFPullToRefreshContentView ()

@property (assign, nonatomic, readwrite) WMFPullToRefreshProgressType type;

@property (strong, nonatomic) PaddedLabel *loadingIndicatorLabel;
@property (strong, nonatomic) PaddedLabel *pullToRefreshLabel;
@property (strong, nonatomic) WMFProgressLineView *progressView;
@property (strong, nonatomic) WMFBorderButton *cancelButton;


@property (nonatomic, assign) BOOL refreshing;
@property (nonatomic, assign) BOOL canceled;
@property (nonatomic, strong) NSTimer* refreshAnimationTimer;
@property (nonatomic, assign) WMPullToRefreshIndeterminateProgressState indeterminateProgressAnimationState;

@end

@implementation WMFPullToRefreshContentView

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame type:(WMFPullToRefreshProgressType)type
{
    self = [super initWithFrame:frame];
    if (self) {
     
        self.backgroundColor = [UIColor whiteColor];
        
        self.type = type;
        
        self.refreshPromptString = MWLocalizedString(@"pull-to-refresh-prompt-default", nil);
        self.refreshReleaseString = MWLocalizedString(@"pull-to-refresh-release-default", nil);
        self.refreshRunningString = MWLocalizedString(@"pull-to-refresh-is-refreshing-default", nil);
        
        self.pullToRefreshLabel = [[PaddedLabel alloc] init];
        self.pullToRefreshLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.pullToRefreshLabel.textAlignment = NSTextAlignmentCenter;
        self.pullToRefreshLabel.numberOfLines = 1;
        self.pullToRefreshLabel.font = [UIFont systemFontOfSize:10.0 * MENUS_SCALE_MULTIPLIER];
        self.pullToRefreshLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:self.pullToRefreshLabel];

        self.loadingIndicatorLabel = [[PaddedLabel alloc] init];
        self.loadingIndicatorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.loadingIndicatorLabel.textAlignment = NSTextAlignmentCenter;
        self.loadingIndicatorLabel.numberOfLines = 1;
        self.loadingIndicatorLabel.font = [UIFont systemFontOfSize:10.0 * MENUS_SCALE_MULTIPLIER];
        self.loadingIndicatorLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:self.loadingIndicatorLabel];

        if(self.type == WMFPullToRefreshProgressTypeDeterminate){
            
            self.progressView = [[WMFProgressLineView alloc] initWithFrame:CGRectZero];
            self.progressView.alpha = 0.0;
            [self addSubview:self.progressView];
            
            self.cancelButton = [WMFBorderButton standardBorderButton];
            [self.cancelButton setTitle:MWLocalizedString(@"saved-pages-clear-cancel", nil) forState:UIControlStateNormal];
            [self.cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
            self.cancelButton.alpha = 0.0;
            [self addSubview:self.cancelButton];
            
        }

    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self setNeedsUpdateConstraints];
}


- (void)updateConstraints{
    
    [super updateConstraints];
    
    [self.pullToRefreshLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self).with.offset(-2.0);
        make.centerX.equalTo(self);
    }];
    
    [self.loadingIndicatorLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.pullToRefreshLabel.mas_top).with.offset(-2.0);
        make.centerX.equalTo(self);
    }];
    
    [self.progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.mas_bottom).with.offset(-self.pullToRefreshView.expandedHeight);
        make.height.equalTo(@4.0);
        make.left.equalTo(self);
        make.right.equalTo(self);
    }];
    
    [self.cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self);
        make.top.equalTo(self.progressView.mas_bottom).with.offset(10.0);
        make.bottom.greaterThanOrEqualTo(self.pullToRefreshLabel.mas_top).with.offset(5.0);
    }];
}

#pragma mark - ivars

- (void)setRefreshing:(BOOL)refreshing{
    
    self.canceled = NO;
    
    _refreshing = refreshing;
    
    if(_refreshing){
        
        [self startAnimatingProgress];
        
    }else{
        
        [self stopAnimatingProgress];
    }
}

#pragma mark - Progress Animation

- (void)startAnimatingProgress{
    
    if(self.type == WMFPullToRefreshProgressTypeIndeterminate){

        self.indeterminateProgressAnimationState = WMPullToRefreshIndeterminateProgressState0;
        self.refreshAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(animateProgressWithTimer:) userInfo:nil repeats:YES];

    }else{

        [self setLoadingProgress:0.0 animated:NO];

        [UIView animateWithDuration:0.2 animations:^{

            self.progressView.alpha = 1.0;
            self.cancelButton.alpha = 1.0;
            self.loadingIndicatorLabel.alpha = 0.0;

        } completion:NULL];
        
        
    }
}

- (void)stopAnimatingProgress{
    
    [self.refreshAnimationTimer invalidate];
    self.refreshAnimationTimer = nil;
    
    [UIView animateWithDuration:0.2 delay:0.5 options:0 animations:^{
        
        self.progressView.alpha = 0.0;
        self.cancelButton.alpha = 0.0;
        self.loadingIndicatorLabel.alpha = 1.0;
        
    } completion:NULL];

}

- (void)animateProgressWithTimer:(NSTimer*)timer{
    
    WMPullToRefreshIndeterminateProgressState newProgress = self.indeterminateProgressAnimationState + 1;
    
    if(newProgress > WMPullToRefreshIndeterminateProgressState3)
        newProgress = WMPullToRefreshIndeterminateProgressState0;
    
    self.indeterminateProgressAnimationState = newProgress;
}

- (void)setIndeterminateProgressAnimationState:(WMPullToRefreshIndeterminateProgressState)animationProgress{
    
    _indeterminateProgressAnimationState = animationProgress;
    
    NSString *loadingText;
    
    switch (animationProgress) {
        case 0:
            loadingText = @"▫︎ ▫︎ ▫︎ ▫︎ ▫︎\n";
            break;
        case 1:
            loadingText = @"▫︎ ▫︎ ▪︎ ▫︎ ▫︎\n";
            break;
        case 2:
            loadingText = @"▫︎ ▪︎ ▪︎ ▪︎ ▫︎\n";
            break;
        case 3:
            loadingText = @"▪︎ ▪︎ ▪︎ ▪︎ ▪︎\n";
            break;
        default:
            loadingText = @"▫︎ ▫︎ ▫︎ ▫︎ ▫︎\n";
            break;
    }
    
    self.loadingIndicatorLabel.text = loadingText;
}

- (void)setLoadingProgress:(float)progress animated:(BOOL)animated{
    
    if(self.canceled)
        progress = 0.0;

    [self.progressView setProgress:progress animated:animated];
    
}

- (void)cancel{
    
    self.canceled = YES;
    
    [self setLoadingProgress:0.0 animated:YES];
    
    if(self.refreshCancelBlock){
        
        self.refreshCancelBlock();
    }
}


#pragma mark - WMFPullToRefreshContentView

- (void)setState:(WMFPullToRefreshViewState)state withPullToRefreshView:(WMFPullToRefreshView *)view{
    
    switch (state) {
        case WMFPullToRefreshViewStateReady: {
            self.pullToRefreshLabel.text = self.refreshReleaseString;
            self.refreshing = NO;
            break;
        }
        case WMFPullToRefreshViewStateNormal: {
            self.pullToRefreshLabel.text = self.refreshPromptString;
            self.refreshing = NO;
            break;
        }
        case WMFPullToRefreshViewStateLoading:{
            self.pullToRefreshLabel.text = self.refreshRunningString;
            self.refreshing = YES;
            break;
        }
        case WMFPullToRefreshViewStateClosing: {
            self.pullToRefreshLabel.text = self.refreshRunningString;
            self.refreshing = NO;
            break;
        }
    }
}


- (void)setPullProgress:(CGFloat)pullProgress{
    
    if(self.refreshing){
        return;
    }
    
    WMPullToRefreshIndeterminateProgressState progress;
    
    if (pullProgress < 0.5) {
        progress = WMPullToRefreshIndeterminateProgressState0;
    }else if (pullProgress < 0.75) {
        progress = WMPullToRefreshIndeterminateProgressState1;
    }else if (pullProgress < 1.0) {
        progress = WMPullToRefreshIndeterminateProgressState2;
    }else{
        progress = WMPullToRefreshIndeterminateProgressState3;
    }
    
    self.indeterminateProgressAnimationState = progress;
}




@end
