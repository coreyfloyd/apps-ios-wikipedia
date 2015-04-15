
#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, WMFCardType) {
    WMFCardTypePrototype1 = 0,
    WMFCardTypePrototype2,
};

@interface WMFCardViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UILabel* articleTitle;
@property (nonatomic, strong) IBOutlet UILabel* wikidataDescription;
@property (nonatomic, strong) IBOutlet UILabel* summary;

@property (nonatomic, assign, readonly) WMFCardType type;

+ (instancetype)cardViewControllerWithType:(WMFCardType)type;


@end