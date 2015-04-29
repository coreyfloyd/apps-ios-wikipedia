
#import <Tweaks/FBTweakInline.h>
#import "WMFCardViewController.h"
#import <Colours/Colours.h>


#ifndef Wikipedia_WMFCardHelpers_h
#define Wikipedia_WMFCardHelpers_h

static inline UIColor* cardbackgroundColor(){
    return [[UIColor colorFromHexString:FBTweakValue(@"Background Overlay", @"Tint", @"Color", @"000000")] colorWithAlphaComponent:FBTweakValue(@"Background Overlay", @"Tint", @"Alpha", 0.2, 0.1, 1.0)];
}

static inline CGFloat cardbackgroundBlur(){
    return FBTweakValue(@"Background Overlay", @"Blur", @"Enabled", NO);
}

static inline CGFloat cardbackgroundBlurRadius(){
    return FBTweakValue(@"Background Overlay", @"Blur", @"Radius", 3.0, 1.0, 50.0);
}

static inline WMFCardType cardPopupType(){
    return FBTweakValue(@"Card", @".Card", @"Prototype", WMFCardTypePrototype2, 1, 2);
}

static inline BOOL cardLoremIpsumEnabled(){
    return FBTweakValue(@"Card", @".Card", @"Lorem Ipsum", NO);
}

static inline CGFloat cardRadius(){
    return FBTweakValue(@"Card", @"Style", @"Corner Radius", 3.0, 0.0, 100.0);
}

static inline CGFloat cardPopupHeight(){
    return FBTweakValue(@"Card", @"Style", @"Height", 270.0, 50.0, 500.0);
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

static inline UIColor* cardImageBackgroundColor(){
    return [UIColor colorFromHexString:FBTweakValue(@"Image", @"Background", @"Color", @"000000")];
}

static inline CGFloat cardImageBlur(){
    return FBTweakValue(@"Image", @"Style", @"Blur Enabled", NO);
}

static inline CGFloat cardImageBlurRadius(){
    return FBTweakValue(@"Image", @"Style", @"Blur Radius", 5.0, 1.0, 50.0);
}

static inline UIColor* cardImageTintColor(){
    return [[UIColor colorFromHexString:FBTweakValue(@"Prototype1", @"Image", @"Overlay Color", @"000000")] colorWithAlphaComponent:FBTweakValue(@"Prototype1", @"Image", @"Overlay Alpha", 0.586, 0.01, 1.0)];
}

//static inline CGFloat cardImageDistanceFromWhite(){
//    return FBTweakValue(@"Prototype2", @"Image", @"Max Distance From White", 20.0, 0.0, 100.0);
//}

static inline UIColor* cardImageDarkTintColor(){
    return [[UIColor colorFromHexString:FBTweakValue(@"Prototype2", @"Image", @"Dark Image Overlay Color", @"000000")] colorWithAlphaComponent:FBTweakValue(@"Prototype2", @"Image", @"Dark Image Overlay Alpha", 0.586, 0.01, 1.0)];
}

static inline UIColor* cardImageLightTintColor(){
    return [[UIColor colorFromHexString:FBTweakValue(@"Prototype2", @"Image", @"Light Image Overlay Color", @"FFFFFF")] colorWithAlphaComponent:FBTweakValue(@"Prototype2", @"Image", @"Dark Image Overlay Alpha", 0.586, 0.01, 1.0)];
}

static inline CGFloat cardImageFadeDuraton(){
    return FBTweakValue(@"Image", @"Fade In Animation", @"Duration", 0.3, 0.0, 1.0);
}

static inline CGFloat cardImageFadeScaleEffect(){
    return FBTweakValue(@"Image", @"Fade In Animation", @"Scale Effect", 0.95, 0.1, 1.0);
}

static NSString* serifFont     = @"Georgia";
static NSString* boldSerifFont = @"Georgia-Bold";


static inline UIFont* cardFont(BOOL serifs, BOOL bold, CGFloat fontSize){
    if (serifs) {
        if (bold) {
            return [UIFont fontWithName:boldSerifFont size:fontSize];
        } else {
            return [UIFont fontWithName:serifFont size:fontSize];
        }
    } else {
        if (bold) {
            return [UIFont boldSystemFontOfSize:fontSize];
        } else {
            return [UIFont systemFontOfSize:fontSize];
        }
    }
}

static inline UIFont* card1TitleFont(){
    return cardFont(FBTweakValue(@"Prototype1", @"Fonts", @"Title Serifs", YES), FBTweakValue(@"Prototype1", @"Fonts", @"Title Bold", NO), (CGFloat)FBTweakValue(@"Prototype1", @"Fonts", @"Title Size", 26.0, 10.0, 50.0));
}

static inline UIFont* card1SummaryFont(){
    return cardFont(FBTweakValue(@"Prototype1", @"Fonts", @"Snippet Serifs", NO), FBTweakValue(@"Prototype1", @"Fonts", @"Snippet Bold", NO), (CGFloat)FBTweakValue(@"Prototype1", @"Fonts", @"Snippet Size", 14.0, 10.0, 50.0));
}

static inline UIFont* card2TitleFont(){
    return cardFont(FBTweakValue(@"Prototype2", @"Fonts", @"Title Serifs", YES), FBTweakValue(@"Prototype2", @"Fonts", @"Title Bold", NO), (CGFloat)FBTweakValue(@"Prototype2", @"Fonts", @"Title Size", 25.2, 10.0, 50.0));
}

static inline UIFont* card2DescriptionFont(){
    return cardFont(FBTweakValue(@"Prototype2", @"Fonts", @"Description Serifs", YES), FBTweakValue(@"Prototype2", @"Fonts", @"Description Bold", NO), (CGFloat)FBTweakValue(@"Prototype2", @"Fonts", @"Description Size", 14.4, 10.0, 50.0));
}

static inline UIFont* card2SummaryFont(){
    return cardFont(FBTweakValue(@"Prototype2", @"Fonts", @"Snippet Serifs", NO), FBTweakValue(@"Prototype2", @"Fonts", @"Snippet Bold", NO), (CGFloat)FBTweakValue(@"Prototype2", @"Fonts", @"Snippet Size", 16.0, 10.0, 50.0));
}

static inline UIFont* cardTitleFont(){
    return (cardPopupType() == WMFCardTypePrototype1) ? card1TitleFont() : card2TitleFont();
}

static inline UIFont* cardDescriptionFont(){
    return card2DescriptionFont();
}

static inline UIFont* cardSummaryFont(){
    return (cardPopupType() == WMFCardTypePrototype1) ? card1SummaryFont() : card2SummaryFont();
}

#endif
