
#import <Tweaks/FBTweakInline.h>
#import "WMFCardViewController.h"
#import <Colours/Colours.h>


#ifndef Wikipedia_WMFCardHelpers_h
#define Wikipedia_WMFCardHelpers_h


static inline WMFCardType cardPopupType(){
    return FBTweakValue(@"Card", @".Card", @"Prototype", WMFCardTypePrototype2, 1, 2);
}

static inline BOOL cardLoremIpsumEnabled(){
    return FBTweakValue(@"Card", @".Card", @"Lorem Ipsum", NO);
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

static NSString* serifFont = @"Georgia";
static NSString* boldSerifFont = @"Georgia-Bold";


static inline UIFont* cardFont(BOOL serifs, BOOL bold, CGFloat fontSize){
    
    if(serifs){
        if(bold){
            return [UIFont fontWithName:boldSerifFont size:fontSize];
            
        }else{
            
            return [UIFont fontWithName:serifFont size:fontSize];
        }
    }else{
        if(bold){
            return [UIFont boldSystemFontOfSize:fontSize];
            
        }else{
            
            return [UIFont systemFontOfSize:fontSize];
        }
    }
}

static inline UIFont* cardTitleFont(){
    return cardFont(FBTweakValue(@"Card", @"Fonts", @"Title Serifs", NO), FBTweakValue(@"Card", @"Fonts", @"Title Bold", YES), (CGFloat)FBTweakValue(@"Card", @"Fonts", @"Title Size", 21.0, 10.0, 50.0));
}

static inline UIFont* cardDescriptionFont(){
    return cardFont(FBTweakValue(@"Card", @"Fonts", @"Description Serifs", NO), FBTweakValue(@"Card", @"Fonts", @"Description Bold", YES), (CGFloat)FBTweakValue(@"Card", @"Fonts", @"Description Size", 18.0, 10.0, 50.0));
}

static inline UIFont* cardSummaryFont(){
    return cardFont(FBTweakValue(@"Card", @"Fonts", @"Snippet Serifs", NO), FBTweakValue(@"Card", @"Fonts", @"Snippet Bold", NO), (CGFloat)FBTweakValue(@"Card", @"Fonts", @"Snippet Size", 16.0, 10.0, 50.0));
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
    return FBTweakValue(@"Card", @"Pop Animation", @"Duration", 0.25, 0.1, 1.0);
}

static inline CGFloat cardAnimationDamping(){
    return FBTweakValue(@"Card", @"Pop Animation", @"Damping", 0.82, 0.0, 1.0);
}

static inline CGFloat cardAnimationVelocity(){
    return FBTweakValue(@"Card", @"Pop Animation", @"Velocity", 0.4, 0.0, 5.0);
}

static inline CGFloat cardImageFadeDuraton(){
    return FBTweakValue(@"Card", @"Image Fade Animation", @"Duration", 0.3, 0.0, 1.0);
}

static inline CGFloat cardImageFadeScaleEffect(){
    return FBTweakValue(@"Card", @"Image Fade Animation", @"Scale Effect", 0.95, 0.1, 1.0);
}

#endif
