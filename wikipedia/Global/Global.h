
#pragma mark - 3rd Party

#import <BlocksKit/BlocksKit.h>
#import <Masonry/Masonry.h>

#pragma mark - Generic Block Definitions

typedef BOOL (^ WMFBOOLBlock)(void);
typedef void (^ WMFSuccessBlock)(BOOL success);
typedef void (^ WMFErrorBlock)(NSError* error);
typedef void (^ WMFFetchBlock)(id object, NSError* error);
typedef void (^ WMFFetchImageBlock)(UIImage* image, NSError* error);
typedef void (^ WMFFetchArrayBlock)(NSArray* array, NSError* error);

#pragma mark - Utility Macros and Functions

#import "WMFMacroUtilities.h"
#import "WMFFunctions.h"

#pragma mark - Foundation extensions

#import "NSObject+Extras.h"
#import "NSString+Extras.h"
#import "NSString+FormattedAttributedString.h"
#import "NSString+WMFHTMLParsing.h"
#import "NSMutableDictionary+WMFMaybeSet.h"
#import "NSArray+Predicate.h"
#import "NSArray+WMFExtensions.h"
#import "NSArray+BKIndex.h"
#import "NSDateFormatter+WMFExtensions.h"
#import "NSDate-Utilities.h"

#pragma mark - UIKit extensions

#import "UIColor+WMFHexColor.h"
#import "UIView+WMFDefaultNib.h"
#import "UIView+WMFFrameUtils.h"
#import "UIView+WMFSearchSubviews.h"
#import "UIView+WMFRoundCorners.h"

#pragma mark - Model Classes

@class MWKDataStore;
@class MWKUserDataStore;

@class MWKDataObject;

@class MWKSite;
@class MWKTitle;
@class MWKArticle;
@class MWKSectionList;
@class MWKSection;

@class MWKImageList;
@class MWKImage;
@class MWKImageInfo;

@class MWKLicense;

@class MWKHistoryList;
@class MWKHistoryEntry;

@class MWKSavedPageList;
@class MWKSavedPageEntry;

@class MWKRecentSearchList;
@class MWKRecentSearchEntry;

@class MWKProtectionStatus;
@class MWKUser;

#pragma mark - Global View Controllers

#warning refactor to remove the following as soon as possible

#import "RootViewController.h"
#import "CenterNavController.h"

#define ROOT ((RootViewController*)[UIApplication sharedApplication].delegate.window.rootViewController)
#define NAV ROOT.centerNavController






