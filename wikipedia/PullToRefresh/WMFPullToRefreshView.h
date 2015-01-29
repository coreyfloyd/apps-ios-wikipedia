
typedef NS_ENUM(NSUInteger, WMFPullToRefreshViewState) {
	/// Most will say "Pull to refresh" in this state
	WMFPullToRefreshViewStateNormal,

	/// Most will say "Release to refresh" in this state
	WMFPullToRefreshViewStateReady,

	/// The view is loading
	WMFPullToRefreshViewStateLoading,

	/// The view has finished loading and is animating
	WMFPullToRefreshViewStateClosing
};

typedef NS_ENUM(NSUInteger, WMFPullToRefreshViewStyle) {
	/// Pull to refresh view will scroll together with the rest of `scrollView` subviews
	WMFPullToRefreshViewStyleScrolling,
	
	/// Pull to refresh view will sit on top of `scrollView` (iOS 7 `UIRefreshControl` style)
	WMFPullToRefreshViewStyleStatic
};

typedef NS_ENUM(NSUInteger, WMFPullToRefreshPullStyle) {
    /// Pull to refresh will begin after the scoll view is released when pulled beyond the minimum distance (Original `Tweetie` style)
    WMFPullToRefreshPullStyleRelease,
    
    /// Pull to refresh will begin immediatelay after when pulled beyond the minimum distance (iOS 7 `UIRefreshControl` style)
    WMFPullToRefreshPullStyleDistance
};

@protocol WMFPullToRefreshContentView;
@protocol WMFPullToRefreshViewDelegate;

@interface WMFPullToRefreshView : UIView

/**
 The content view displayed when the `scrollView` is pulled down.

 @see WMPullToRefreshContentView
 */
@property (nonatomic, strong) UIView<WMFPullToRefreshContentView> *contentView;

/**
 If you need to update the scroll view's content inset while it contains a pull to refresh view, you should set the
 `defaultContentInset` on the pull to refresh view and it will forward it to the scroll view taking into account the
 pull to refresh view's position.
 */
@property (nonatomic, assign) UIEdgeInsets defaultContentInset;

/**
 The height of the fully expanded content view. The default is `70.0`.

 The `contentView`'s `sizeThatFits:` will be respected when displayed but does not effect the expanded height. You can use this
 to draw outside of the expanded area. If you don't implement `sizeThatFits:` it will automatically display at the default size.

 @see expanded
 */
@property (nonatomic, assign) CGFloat expandedHeight;

@property (nonatomic, assign) CGFloat compactExpandedHeight;


/**
 A boolean indicating if the pull to refresh view is expanded.

 @see expandedHeight
 @see startLoadingAndExpand:
 */
@property (nonatomic, assign, readonly, getter = isExpanded) BOOL expanded;

/**
 The scroll view containing the pull to refresh view. This is automatically set with `initWithScrollView:delegate:`.

 @see initWithScrollView:delegate:
 */
@property (nonatomic, weak, readonly) UIScrollView *scrollView;

/**
 The delegate is sent messages when the pull to refresh view starts loading. This is automatically set with `initWithScrollView:delegate:`.

 @see initWithScrollView:delegate:
 @see SSPullToRefreshViewDelegate
 */
@property (nonatomic, weak) id<WMFPullToRefreshViewDelegate> delegate;

/**
 The state of the pull to refresh view.

 @see startLoading
 @see startLoadingAndExpand:
 @see finishLoading
 @see WMFPullToRefreshViewState
 */
@property (nonatomic, assign, readonly) WMFPullToRefreshViewState state;

/**
 A pull to refresh view style. The default is `WMFPullToRefreshViewStyleScrolling`.
 */
@property (nonatomic, assign) WMFPullToRefreshViewStyle viewStyle;

/**
 A pull to refresh pull style. The default is `WMFPullToRefreshPullStyleRelease`.
 */
@property (nonatomic, assign) WMFPullToRefreshPullStyle pullStyle;

/**
 All you need to do to add this view to your scroll view is call this method (passing in the scroll view). That's it.
 You don't have to add it as subview or anything else. The rest is magic.

 You should only initalize with this method and never move it to another scroll view during its lifetime.
 */
- (id)initWithScrollView:(UIScrollView *)scrollView delegate:(id<WMFPullToRefreshViewDelegate>)delegate;

/**
 Call this method when you start loading. If you trigger loading another way besides pulling to refresh, call this
 method so the pull to refresh view will be in sync with the loading status. By default, it will not expand the view
 so it loads quietly out of view.
 */
- (void)startLoading;

/**
 Call this method when you start loading. If you trigger loading another way besides pulling to refresh, call this
 method so the pull to refresh view will be in sync with the loading status. You may pass YES for shouldExpand to
 animate down the pull to refresh view to show that it's loading.
 */
- (void)startLoadingAndExpand:(BOOL)shouldExpand animated:(BOOL)animated;
- (void)startLoadingAndExpand:(BOOL)shouldExpand animated:(BOOL)animated completion:(void(^)())block;

/**
 Call this method when you want to inform the refresh view of the loading progress.
 */
- (void)updateLoadingProgress:(float)progress animated:(BOOL)animated;

/**
 Call this when you finish loading.
 */
- (void)finishLoading;
- (void)finishLoadingAnimated:(BOOL)animated completion:(void(^)())block;

/**
 Manually update the last updated at time. This will automatically get called when the pull to refresh view finishes loading.
 */
- (void)refreshLastUpdatedAt;


/**
 *  Call to tear down - This may be called at anytime, but generally should be called in the dealloc method of your view controller
 */
- (void)uninstall;

@end


@protocol WMFPullToRefreshViewDelegate <NSObject>

@optional

/**
 Return `NO` if the pull to refresh view should not start loading.
 */
- (BOOL)pullToRefreshViewShouldStartLoading:(WMFPullToRefreshView *)view;

/**
 The pull to refresh view started loading. You should kick off whatever you need to load when this is called.
 */
- (void)pullToRefreshViewDidStartLoading:(WMFPullToRefreshView *)view;

/**
 The pull to refresh view finished loading. This will get called when it receives `finishLoading`.
 */
- (void)pullToRefreshViewDidFinishLoading:(WMFPullToRefreshView *)view;

/**
 The date when data was last updated. This will get called when it finishes loading or if it receives `refreshLastUpdatedAt`.
 Some content views may display this date.
 */
- (NSDate *)pullToRefreshViewLastUpdatedAt:(WMFPullToRefreshView *)view;

/**
 The pull to refresh view updated its scroll view's content inset
 */
- (void)pullToRefreshView:(WMFPullToRefreshView *)view didUpdateContentInset:(UIEdgeInsets)contentInset;

/**
 The pull to refresh view will change state.
 */
- (void)pullToRefreshView:(WMFPullToRefreshView *)view willTransitionToState:(WMFPullToRefreshViewState)toState fromState:(WMFPullToRefreshViewState)fromState animated:(BOOL)animated;

/**
 The pull to refresh view did change state.
 */
- (void)pullToRefreshView:(WMFPullToRefreshView *)view didTransitionToState:(WMFPullToRefreshViewState)toState fromState:(WMFPullToRefreshViewState)fromState animated:(BOOL)animated;

@end


@protocol WMFPullToRefreshContentView <NSObject>

@required

@property (weak, nonatomic) WMFPullToRefreshView* pullToRefreshView;

/**
 The pull to refresh view's state has changed. The content view must update itself. All content view's must implement
 this method.
 */
- (void)setState:(WMFPullToRefreshViewState)state withPullToRefreshView:(WMFPullToRefreshView *)view;

@optional

/**
 The pull to refresh view will set send values from `0.0` to `1.0` (or higher if the user keeps pulling) as the user
 pulls down. `1.0` means it is fully expanded and will change to the `WMFPullToRefreshViewStateReady` state. You can use
 this value to draw the progress of the pull (i.e. Tweetbot style).
 */
- (void)setPullProgress:(CGFloat)pullProgress;

/**
 The pull to refresh view will send updates of the loading progress which can be displayed by the content view.
 */
- (void)setLoadingProgress:(float)progress animated:(BOOL)animated;

/**
 The pull to refresh view updated its last updated date.
 */
- (void)setLastUpdatedAt:(NSDate *)date withPullToRefreshView:(WMFPullToRefreshView *)view;

@end
