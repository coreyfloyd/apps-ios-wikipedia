//
//  CardView.m
//  gftbk
//
//  Created by Neeraj Baid on 3/21/14.
//  Copyright (c) 2014 Neeraj Baid. All rights reserved.
//

#import "NBSlideUpView.h"
#import <Masonry/Masonry.h>
#import "WMFCardHelpers.h"
#import "UIColor+WMFHexColor.h"
#import "UIImage+ImageEffects.h"
#import "UIView+SnapShot.h"


@interface NBSlideUpView ()

@property (nonatomic, strong) UIImageView* backgroundBlur;
@property (nonatomic, strong) UIView* backgroundView;
@property (nonatomic, strong) UIView* slideOutContainer;

@end

@implementation NBSlideUpView


- (instancetype)init {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        UIImageView* backgroundBlur = [[UIImageView alloc] initWithFrame:self.bounds];
        backgroundBlur.alpha = 0.0;

        [self addSubview:backgroundBlur];

        self.backgroundBlur = backgroundBlur;

        UIView* background = [[UIView alloc] initWithFrame:self.bounds];
        background.backgroundColor = [UIColor wmf_colorWithHexString:cardbackgroundColor() alpha:cardbackgroundAlpha()];
        background.alpha           = 0.0;

        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapWithGesture:)];
        [background addGestureRecognizer:tap];

        [self addSubview:background];

        self.backgroundView = background;

        UIView* slideOutContainer = [[UIView alloc] initWithFrame:CGRectZero];
        slideOutContainer.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.4];
        slideOutContainer.backgroundColor = [UIColor clearColor];

        [self addSubview:slideOutContainer];

        self.slideOutContainer = slideOutContainer;

        _visible        = NO;
        _viewablePixels = 100.0;

        self.initialSpringVelocity = 1;
        self.animateInOutTime      = 0.5;
        self.springDamping         = 0.8;
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];

    if (self.superview) {
        [self mas_remakeConstraints:^(MASConstraintMaker* make) {
            make.edges.equalTo(self.superview);
        }];

        [self layoutIfNeeded];

        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];

        if (cardbackgroundBlur()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage* image = [self.superview snapshotOfContents];
                image = [image applyBlurWithRadius:cardbackgroundBlurRadius() tintColor:nil saturationDeltaFactor:1.8 maskImage:nil];
                self.backgroundBlur.image = image;
            });
        }
    }
}

- (void)updateConstraints {
    [super updateConstraints];

    [self.backgroundBlur mas_remakeConstraints:^(MASConstraintMaker* make) {
        make.edges.equalTo(self);
    }];

    [self.backgroundView mas_remakeConstraints:^(MASConstraintMaker* make) {
        make.edges.equalTo(self);
    }];

    [_contentView mas_updateConstraints:^(MASConstraintMaker* make) {
        make.edges.equalTo(self.slideOutContainer);
    }];

    [_slideOutContainer mas_remakeConstraints:^(MASConstraintMaker* make) {
        if (self.visible) {
            make.top.equalTo(self.mas_bottom).with.offset(-self->_viewablePixels);
        } else {
            make.top.equalTo(self.mas_bottom);
        }

        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.equalTo(@(self->_viewablePixels));
    }];
}

- (void)setContentView:(UIView*)contentView {
    if (![_contentView isEqual:contentView]) {
        [_contentView removeFromSuperview];

        _contentView = contentView;

        [self.slideOutContainer addSubview:_contentView];
    }
}

- (void)setVisible:(BOOL)visible {
    if (_visible != visible) {
        _visible = visible;

        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
        [self layoutIfNeeded];
    }
}

- (void)setViewablePixels:(CGFloat)viewablePixels {
    if (_viewablePixels != viewablePixels) {
        _viewablePixels = viewablePixels;

        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
        [self layoutIfNeeded];
    }
}

//#pragma mark - Touches/Dragging
//
//- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
//{
//    UITouch* touch = [touches anyObject];
//    CGPoint location = [touch locationInView:self.superview];
//    if (self.previousTouch.y == 0)
//        _previousTouch = location;
//    CGFloat translation = location.y - self.previousTouch.y;
//    [self setCenter:CGPointMake(self.center.x, self.center.y + translation)];
//    _previousTouch = location;
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    _previousTouch = CGPointMake(0, 0);
//    if (self.frame.origin.y > self.superview.frame.size.height - self.viewablePixels)
//        [self animateOut];
//    else
//        [self animateRestore];
//}


- (void)animateIn {
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        ((UIScrollView*)self.superview).scrollEnabled = NO;
    }

    [UIView animateWithDuration:self.animateInOutTime delay:0 usingSpringWithDamping:self.springDamping initialSpringVelocity:self.initialSpringVelocity options:UIViewAnimationOptionCurveEaseInOut animations:^(void)
    {
        self.backgroundBlur.alpha = 1.0;
        self.backgroundView.alpha = 1.0;
        self.visible = YES;
    }                completion:^(BOOL completed){
        if (completed) {
            [self.delegate slideUpViewDidAnimateIn:self];
        }
    }];
}

- (void)animateOut {
    [UIView animateWithDuration:self.animateInOutTime delay:0 usingSpringWithDamping:self.springDamping initialSpringVelocity:self.initialSpringVelocity options:UIViewAnimationOptionCurveEaseInOut animations:^(void)
    {
        self.backgroundBlur.alpha = 0.0;
        self.backgroundView.alpha = 0.0;
        self.visible = NO;
    }                completion:^(BOOL completed) {
        if ([self.superview isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView*)self.superview).scrollEnabled = YES;
        }

        if (completed) {
            [self.delegate slideUpViewDidAnimateOut:self];
        }
    }];
}

#pragma mark - UITapGestureRecognizerDelegate

- (void)didTapWithGesture:(UITapGestureRecognizer*)tap {
    [self animateOut];
}

@end
