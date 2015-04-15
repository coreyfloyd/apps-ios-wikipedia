//
//  CardView.h
//  Based on NBSlideUpView https://github.com/neerajbaid/NBSlideUpView by
//
//  Copyright (c) 2014 Neeraj Baid. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NBSlideUpViewDelegate <NSObject>

- (void)slideUpViewDidAnimateOut:(UIView*)slideUpView;
- (void)slideUpViewDidAnimateIn:(UIView*)slideUpView;

@end

@interface NBSlideUpView : UIView <UIAlertViewDelegate>

- (instancetype)init;

- (void)animateOut;
- (void)animateIn;

@property (nonatomic) BOOL visible;


@property (nonatomic) CGFloat viewablePixels;

@property (nonatomic) CGFloat springDamping;
@property (nonatomic) CGFloat initialSpringVelocity;
@property (nonatomic) CGFloat animateInOutTime;

@property (nonatomic, strong) UIView* contentView;

@property (nonatomic, strong) id<NBSlideUpViewDelegate> delegate;

@end
