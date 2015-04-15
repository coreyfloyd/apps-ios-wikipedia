
#import <Tweaks/FBTweakInline.h>
#import "WMFCardViewController.h"


#ifndef Wikipedia_WMFCardHelpers_h
#define Wikipedia_WMFCardHelpers_h


static inline WMFCardType cardPopupType(){
    
    return [FBTweakValue(@"Card", @"Style", @"Type", @(WMFCardTypePrototype1)) unsignedIntegerValue];
   
}

static inline CGFloat cardPopupHeight(){
    
    return FBTweakValue(@"Card", @"Style", @"Height", 200.0, 50.0, 400.0);
    
}


static inline CGFloat cardAnimationDuration(){
    
    return FBTweakValue(@"Card", @"Animation", @"Duration", 0.25, 0.1, 1.0);
    
}

#endif
