
#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, WMFCardType) {
    WMFCardTypePrototype1 = 1,
    WMFCardTypePrototype2,
};

@interface WMFCardViewController : UIViewController

+ (instancetype)cardViewControllerWithType:(WMFCardType)type pageTitle:(MWKTitle*)title;

@property (nonatomic, assign, readonly) WMFCardType type;
@property (nonatomic, strong, readonly) MWKTitle* pageTitle;

@end
