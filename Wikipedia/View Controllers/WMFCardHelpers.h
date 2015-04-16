
#import <Tweaks/FBTweakInline.h>
#import "WMFCardViewController.h"
#import <Colours/Colours.h>


#ifndef Wikipedia_WMFCardHelpers_h
#define Wikipedia_WMFCardHelpers_h


static inline WMFCardType cardPopupType(){
    return FBTweakValue(@"Card", @".Card", @"Prototype", WMFCardTypePrototype2, 0, 1);
}

static inline CGFloat cardRadius(){
    return FBTweakValue(@"Card", @"Style", @"Corner Radius", 15.0, 0.0, 100.0);
}

static inline CGFloat cardPopupHeight(){
    return FBTweakValue(@"Card", @"Style", @"Height", 300.0, 50.0, 500.0);
}

static inline UIColor* cardbackgroundColor(){
    return [[UIColor colorFromHexString:FBTweakValue(@"Background", @"Tint", @"Color", @"000000")] colorWithAlphaComponent:FBTweakValue(@"Background", @"Tint", @"Alpha", 0.2, 0.1, 1.0)];
}

static inline CGFloat cardbackgroundBlur(){
    return FBTweakValue(@"Background", @"Blur", @"Enabled", NO);
}

static inline CGFloat cardbackgroundBlurRadius(){
    return FBTweakValue(@"Background", @"Blur", @"Radius", 3.0, 1.0, 50.0);
}

static inline CGFloat cardTitleFontSize(){
    return (CGFloat)FBTweakValue(@"Card", @"Fonts", @"Title Size", 21.0, 10.0, 50.0);
}

static inline CGFloat cardDescriptionFontSize(){
    return (CGFloat)FBTweakValue(@"Card", @"Fonts", @"Wikidata Description Size", 17.0, 10.0, 50.0);
}

static inline CGFloat cardSummaryFontSize(){
    return (CGFloat)FBTweakValue(@"Card", @"Fonts", @"Summary Size", 15.0, 10.0, 40.0);
}

static inline UIColor* cardImageBackgroundColor(){
    return [UIColor colorFromHexString:FBTweakValue(@"Card", @"Image", @"Background Color", @"303030")];
}

static inline CGFloat cardImageBlur(){
    return FBTweakValue(@"Card", @"Image", @"Blur Enabled", YES);
}

static inline CGFloat cardImageBlurRadius(){
    return FBTweakValue(@"Card", @"Image", @"Blur Radius", 5.0, 1.0, 50.0);
}

static inline UIColor* cardImageTintColor(){
    return [[UIColor colorFromHexString:FBTweakValue(@"Card", @"Image", @"Tint Color (P1 only)", @"000000")] colorWithAlphaComponent:FBTweakValue(@"Card", @"Image", @"Tint Alpha", 0.20, 0.01, 1.0)];
}

static inline CGFloat cardAnimationDuration(){
    return FBTweakValue(@"Card", @"Animation", @"Duration", 0.25, 0.1, 1.0);
}

static inline CGFloat cardAnimationDamping(){
    return FBTweakValue(@"Card", @"Animation", @"Damping", 0.82, 0.0, 1.0);
}

static inline CGFloat cardAnimationVelocity(){
    return FBTweakValue(@"Card", @"Animation", @"Velocity", 0.4, 0.0, 5.0);
}

#endif
