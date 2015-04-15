
#import <Tweaks/FBTweakInline.h>
#import "WMFCardViewController.h"


#ifndef Wikipedia_WMFCardHelpers_h
#define Wikipedia_WMFCardHelpers_h


static inline WMFCardType cardPopupType(){
    
    return FBTweakValue(@"Card", @"Style", @"Type", WMFCardTypePrototype1, 0, 1);
}

static inline CGFloat cardPopupHeight(){
    
    return FBTweakValue(@"Card", @"Style", @"Height", 300.0, 50.0, 500.0);
}

static inline CGFloat cardTitleFontSize(){
    
    return (CGFloat)FBTweakValue(@"Card", @"Fonts", @"Title Size", 17, 10, 40);
}

static inline CGFloat cardDescriptionFontSize(){
    
    return (CGFloat)FBTweakValue(@"Card", @"Fonts", @"Wikidata Description Size", 15, 10, 40);
}

static inline CGFloat cardSummaryFontSize(){
    
    return (CGFloat)FBTweakValue(@"Card", @"Fonts", @"Summary Size", 12, 10, 40);
}

static inline CGFloat cardAnimationDuration(){
    
    return FBTweakValue(@"Card", @"Animation", @"Duration", 0.25, 0.1, 1.0);
}

#endif
