
#import "WMFPullToRefreshView.h"
#import "WMFPullToRefreshContentView.h"
#import <QuartzCore/QuartzCore.h>

@interface WMFPullToRefreshView ()
@property (nonatomic, readwrite) WMFPullToRefreshViewState state;
@property (nonatomic, readwrite) UIScrollView *scrollView;
@property (nonatomic, readwrite, getter = isExpanded) BOOL expanded;
@property (nonatomic) CGFloat topInset;
@property (nonatomic) dispatch_semaphore_t animationSemaphore;
@end

@implementation WMFPullToRefreshView

@synthesize contentView = _contentView;
@synthesize expandedHeight = _expandedHeight;

#pragma mark - Accessors

- (void)setState:(WMFPullToRefreshViewState)state {
	BOOL wasLoading = _state == WMFPullToRefreshViewStateLoading;
    _state = state;

	// Forward to content view
	[self.contentView setState:_state withPullToRefreshView:self];

	// Update delegate
	id<WMFPullToRefreshViewDelegate> delegate = self.delegate;
	if (wasLoading && _state != WMFPullToRefreshViewStateLoading) {
		if ([delegate respondsToSelector:@selector(pullToRefreshViewDidFinishLoading:)]) {
			[delegate pullToRefreshViewDidFinishLoading:self];
		}
	} else if (!wasLoading && _state == WMFPullToRefreshViewStateLoading) {
		[self _setPullProgress:1.0f];
        
        if(self.pullStyle == WMFPullToRefreshPullStyleDistance){
            
            CGPoint p = self.scrollView.contentOffset;
            UIEdgeInsets e = self.scrollView.contentInset;
            self.scrollView.panGestureRecognizer.enabled = NO;
            [self.scrollView setContentOffset:p animated:NO];
            [self.scrollView setContentInset:e];
            self.scrollView.panGestureRecognizer.enabled = YES;
        }
        
		if ([delegate respondsToSelector:@selector(pullToRefreshViewDidStartLoading:)]) {
			[delegate pullToRefreshViewDidStartLoading:self];
		}
	}
}

- (void)setExpanded:(BOOL)expanded {
	_expanded = expanded;
	[self _setContentInsetTop:expanded ? self.expandedHeight : 0.0f];
    
    if (!expanded && self.scrollView.contentOffset.y <= 0.0f) {
        [self.scrollView setContentOffset:CGPointZero animated:YES];
    }
}

- (void)setExpandedHeight:(CGFloat)expandedHeight{
    
    _expandedHeight = expandedHeight;
    [self.contentView setNeedsLayout];
    [self.contentView setNeedsUpdateConstraints];
}

- (void)setCompactExpandedHeight:(CGFloat)compactExpandedHeight{
    
    _compactExpandedHeight = compactExpandedHeight;
    [self.contentView setNeedsLayout];
    [self.contentView setNeedsUpdateConstraints];
}

- (CGFloat)expandedHeight{
    
    if(_compactExpandedHeight && UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
        return _compactExpandedHeight;
    
    return _expandedHeight;
}


- (void)setScrollView:(UIScrollView *)scrollView {
	void *context = (__bridge void *)self;
	if ([_scrollView respondsToSelector:@selector(removeObserver:forKeyPath:context:)]) {
		[_scrollView removeObserver:self forKeyPath:@"contentOffset" context:context];
	} else if (_scrollView) {
		[_scrollView removeObserver:self forKeyPath:@"contentOffset"];
	}

	_scrollView = scrollView;
	self.defaultContentInset = _scrollView.contentInset;
	[_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:context];
}


- (UIView<WMFPullToRefreshContentView> *)contentView {
    // Use the simple content view as the default
    if (!_contentView) {
        _contentView = [[WMFPullToRefreshContentView alloc] initWithFrame:CGRectZero type:WMFPullToRefreshProgressTypeIndeterminate];
    }
    return _contentView;
}


- (void)setContentView:(UIView<WMFPullToRefreshContentView> *)contentView {
    _contentView.pullToRefreshView = nil;
    [_contentView removeFromSuperview];
    _contentView = contentView;
    
    [_contentView setState:self.state withPullToRefreshView:self];
    [self refreshLastUpdatedAt];
    [self addSubview:_contentView];
    _contentView.pullToRefreshView = self;
    [_contentView setNeedsLayout];
    [_contentView setNeedsUpdateConstraints];
}


- (void)setDefaultContentInset:(UIEdgeInsets)defaultContentInset {
	_defaultContentInset = defaultContentInset;
	[self _setContentInsetTop:self.topInset];
}


- (void)setViewStyle:(WMFPullToRefreshViewStyle)style {
	_viewStyle = style;
	[self setNeedsLayout];
}


- (void)uninstall{
    
    [self removeFromSuperview];
}



#pragma mark - NSObject

- (void)dealloc {
	self.scrollView = nil;
	self.delegate = nil;
#if !OS_OBJECT_USE_OBJC
	dispatch_release(_animationSemaphore);
#endif
}


#pragma mark - UIView

- (void)removeFromSuperview {
	self.scrollView = nil;
	[super removeFromSuperview];
}


- (void)layoutSubviews {
    
    [super layoutSubviews];
    
	CGSize size = self.bounds.size;
	CGSize contentSize = [self.contentView sizeThatFits:size];

	if (contentSize.width < size.width) {
		contentSize.width = size.width;
	}

	if (contentSize.height < self.expandedHeight) {
		contentSize.height = self.expandedHeight;
	}

	CGRect contentFrame;
	contentFrame.origin.x = roundf((size.width - contentSize.width) / 2.0f);
	contentFrame.size = contentSize;
	switch (self.viewStyle) {
		case WMFPullToRefreshViewStyleScrolling:
			contentFrame.origin.y = size.height - contentSize.height;
			break;
        case WMFPullToRefreshViewStyleStatic:{
            contentFrame.origin.y = size.height - contentSize.height;
            if(self.state == WMFPullToRefreshViewStateLoading){
                contentFrame.origin.y += self.scrollView.contentOffset.y + self.expandedHeight /*(self.defaultContentInset.top)*/;
            }
        }
			break;
	}

	self.contentView.frame = contentFrame;
}


#pragma mark - Initializer

- (id)initWithScrollView:(UIScrollView *)scrollView delegate:(id<WMFPullToRefreshViewDelegate>)delegate {
	CGRect frame = CGRectMake(0.0f, 0.0f - scrollView.bounds.size.height, scrollView.bounds.size.width,
							  scrollView.bounds.size.height);
	if ((self = [self initWithFrame:frame])) {
		for (UIView *view in self.scrollView.subviews) {
			if ([view isKindOfClass:[WMFPullToRefreshView class]]) {
				[[NSException exceptionWithName:@"WMFPullToRefreshViewAlreadyAdded" reason:@"There is already a WMFPullToRefreshView added to this scroll view. Unexpected things will happen. Don't do this." userInfo:nil] raise];
			}
		}

		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.scrollView = scrollView;
		self.delegate = delegate;
		self.state = WMFPullToRefreshViewStateNormal;
		self.expandedHeight = 70.0f;
		self.defaultContentInset = scrollView.contentInset;

		// Add to scroll view
		[self.scrollView addSubview:self];

		// Semaphore is used to ensure only one animation plays at a time
		_animationSemaphore = dispatch_semaphore_create(0);
		dispatch_semaphore_signal(_animationSemaphore);

	}
	return self;
}


#pragma mark - Loading

- (void)startLoading {
	[self startLoadingAndExpand:NO animated:NO];
}


- (void)startLoadingAndExpand:(BOOL)shouldExpand animated:(BOOL)animated {
	[self startLoadingAndExpand:shouldExpand animated:animated completion:nil];
}

- (void)startLoadingAndExpand:(BOOL)shouldExpand animated:(BOOL)animated completion:(void(^)())block {
	// If we're not loading, this method has no effect
    if (self.state == WMFPullToRefreshViewStateLoading) {
		return;
	}
	
	// Animate back to the loading state
	[self _setState:WMFPullToRefreshViewStateLoading animated:animated expanded:shouldExpand completion:^{
        
        [self.scrollView setContentOffset:CGPointMake(0, -self.expandedHeight) animated:animated];
        
        if(block)
            block();
    }];
}

- (void)updateLoadingProgress:(float)progress animated:(BOOL)animated{
    
    // Forward to content view
    if ([self.contentView respondsToSelector:@selector(setLoadingProgress:animated:)]) {
        [self.contentView setLoadingProgress:progress animated:animated];
    }
}


- (void)finishLoading {
	[self finishLoadingAnimated:YES completion:nil];
}

- (void)finishLoadingAnimated:(BOOL)animated completion:(void(^)())block {
    
    // If we're not loading, this method has no effect
    if (self.state != WMFPullToRefreshViewStateLoading) {
		return;
	}
	
    //Adding a delay here to give the content view a chance to update its UI before closing.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        // Animate back to the normal state
        __weak WMFPullToRefreshView *blockSelf = self;
        [self _setState:WMFPullToRefreshViewStateClosing animated:animated expanded:NO completion:^{
            blockSelf.state = WMFPullToRefreshViewStateNormal;
            
            if (block) {
                block();
            }
        }];
        
        [self refreshLastUpdatedAt];
    });

}


- (void)refreshLastUpdatedAt {
	NSDate *date = nil;
	id<WMFPullToRefreshViewDelegate> delegate = self.delegate;
	if ([delegate respondsToSelector:@selector(pullToRefreshViewLastUpdatedAt:)]) {
		date = [delegate pullToRefreshViewLastUpdatedAt:self];
	} else {
		date = [NSDate date];
	}

	// Forward to content view
	if ([self.contentView respondsToSelector:@selector(setLastUpdatedAt:withPullToRefreshView:)]) {
		[self.contentView setLastUpdatedAt:date withPullToRefreshView:self];
	}
}


#pragma mark - Private

- (void)_setContentInsetTop:(CGFloat)topInset {
    
	self.topInset = topInset;

	// Default to the scroll view's initial content inset
	UIEdgeInsets inset = self.defaultContentInset;

	// Add the top inset
	inset.top += self.topInset;

	// Don't set it if that is already the current inset
	if (self.scrollView.contentInset.top == inset.top) {
		return;
	}

	self.scrollView.contentInset = inset;

	// For static style, trigger layout subviews immediately to prevent jumping
	if (self.viewStyle == WMFPullToRefreshViewStyleStatic) {
		[self setNeedsLayout];
		[self layoutIfNeeded];
	}

	// Tell the delegate
	id<WMFPullToRefreshViewDelegate> delegate = self.delegate;
	if ([delegate respondsToSelector:@selector(pullToRefreshView:didUpdateContentInset:)]) {
		[delegate pullToRefreshView:self didUpdateContentInset:self.scrollView.contentInset];
	}
}

- (void)_setLoadingState{
    
    // We're ready, prepare to switch to loading. Be default, we should refresh.
    WMFPullToRefreshViewState newState = WMFPullToRefreshViewStateLoading;
    
    // Ask the delegate if it's cool to start loading
    BOOL expand = YES;
    id<WMFPullToRefreshViewDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(pullToRefreshViewShouldStartLoading:)]) {
        if (![delegate pullToRefreshViewShouldStartLoading:self]) {
            // Animate back to normal since the delegate said no
            newState = WMFPullToRefreshViewStateNormal;
            expand = NO;
        }
    }
    
    // Animate to the new state
    [self _setState:newState animated:YES expanded:expand completion:nil];
   
}


- (void)_setState:(WMFPullToRefreshViewState)state animated:(BOOL)animated expanded:(BOOL)expanded completion:(void (^)(void))completion {
	WMFPullToRefreshViewState fromState = self.state;

	id delegate = self.delegate;
	if ([delegate respondsToSelector:@selector(pullToRefreshView:willTransitionToState:fromState:animated:)]) {
		[delegate pullToRefreshView:self willTransitionToState:state fromState:fromState animated:animated];
	}

	if (!animated) {
		self.state = state;
		self.expanded = expanded;

		if (completion) {
			completion();
		}

		if ([delegate respondsToSelector:@selector(pullToRefreshView:didTransitionToState:fromState:animated:)]) {
			[delegate pullToRefreshView:self didTransitionToState:state fromState:fromState animated:animated];
		}

		return;
	}

	__weak WMFPullToRefreshView *weakSelf = self;
	dispatch_semaphore_t semaphore = self.animationSemaphore;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
		dispatch_async(dispatch_get_main_queue(), ^{
			[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
				self.state = state;
				self.expanded = expanded;
			} completion:^(BOOL finished) {
				dispatch_semaphore_signal(semaphore);
				if (completion) {
					completion();
				}

				if ([delegate respondsToSelector:@selector(pullToRefreshView:didTransitionToState:fromState:animated:)]) {
					[delegate pullToRefreshView:weakSelf didTransitionToState:state fromState:fromState animated:animated];
				}
			}];
		});
	});
}


- (void)_setPullProgress:(CGFloat)pullProgress {
    
    // Don't do anything if the content view doesn't implement the method
	if (![self.contentView respondsToSelector:@selector(setPullProgress:)]) {
		return;
	}

	// Ensure the value is between 0 and 1 (or higher if they keep pulling)
	pullProgress = fmaxf(0.0f, pullProgress);

	// Notify the content view
	[self.contentView setPullProgress:pullProgress];
}


#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	// Call super if we didn't register for this notification
	if (context != (__bridge void *)self) {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
		return;
	}

	// We don't care about this notificaiton
	if (object != self.scrollView || ![keyPath isEqualToString:@"contentOffset"]) {
		return;
	}

	// Need to layout subviews for static style
	if (self.viewStyle == WMFPullToRefreshViewStyleStatic) {
		[self setNeedsLayout];
	}
    
	// Get the offset out of the change notification
	CGFloat y = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue].y + self.defaultContentInset.top;

	// Scroll view is dragging
	if (self.scrollView.isDragging) {
		// Scroll view is ready
		if (self.state == WMFPullToRefreshViewStateReady) {
			// Dragged enough to refresh
			if (y > -self.expandedHeight && y < 0.0f) {
				self.state = WMFPullToRefreshViewStateNormal;
			}
		// Scroll view is normal
		} else if (self.state == WMFPullToRefreshViewStateNormal) {
			// Update the content view's pulling progressing
			[self _setPullProgress:-y / self.expandedHeight];

			// Dragged enough to be ready
			if (y < -self.expandedHeight) {
                if(self.pullStyle == WMFPullToRefreshPullStyleRelease){
                    self.state = WMFPullToRefreshViewStateReady;
                }else{
                    
                    [self _setLoadingState];
                }
			}
		// Scroll view is loading
		} else if (self.state == WMFPullToRefreshViewStateLoading) {
            CGFloat insetAdjustment = y < 0 ? fmaxf(0, self.expandedHeight + y) : self.expandedHeight;
			[self _setContentInsetTop:self.expandedHeight - insetAdjustment];
		}
		return;
	} else if (self.scrollView.isDecelerating) {
		[self _setPullProgress:-y / self.expandedHeight];
	}

	// If the scroll view isn't ready, we're not interested
	if (self.state != WMFPullToRefreshViewStateReady) {
		return;
	}

    [self _setLoadingState];
}

@end
