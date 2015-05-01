
#import "WMFCardViewController.h"

#import <BlocksKit/BlocksKit.h>
#import "AFHTTPRequestOperationManager+WMFApiRequestManager.h"
#import "AFHTTPRequestOperationManager+UniqueRequests.h"
#import "MWKArticlePreviewResponseSerializer.h"
#import "WMFNetworkUtilities.h"
#import "SessionSingleton.h"
#import "WMFApiRequestParameters+ArticlePreview.h"
#import "MWKTitle.h"
#import "MWKArticlePreview.h"


#import <LoremIpsum/LoremIpsum.h>
#import "WMFCardHelpers.h"
#import <Colours/Colours.h>
#import <UIImage+AverageColor/UIImage+AverageColor.h>
#import "UIImage+ImageEffects.h"
#import "UIView+SnapShot.h"
#import <Masonry/Masonry.h>
#import <NYXImagesKit/NYXImagesKit.h>


@interface WMFCardViewController ()

@property (nonatomic, copy) AFHTTPRequestOperationManager* requestManager;
@property (nonatomic, strong) id <AFURLResponseSerialization> imageResponseSerializer;
@property (readwrite, nonatomic, strong) AFHTTPRequestOperation* imageRequestOperation;

@property (strong, nonatomic) IBOutlet UIView* imageViewBackground;
@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (strong, nonatomic) IBOutlet UIView* imageTIntView;

@property (nonatomic, strong) IBOutlet UILabel* articleTitle;
@property (nonatomic, strong) IBOutlet UILabel* wikidataDescription;
@property (nonatomic, strong) IBOutlet UILabel* summary;

@property (nonatomic, assign, readwrite) WMFCardType type;
@property (nonatomic, strong, readwrite) MWKTitle* pageTitle;


@end

CGSize proportionalSizeByChangingHeight(CGSize originalSize, CGFloat newHeight){
    CGFloat newWidth = (originalSize.width / originalSize.height) * newHeight;
    return CGSizeMake(newWidth, newHeight);
}

CGSize proportionalSizeByChangingWidth(CGSize originalSize, CGFloat newWidth){
    CGFloat newHeight = (originalSize.width / originalSize.height) / newWidth;
    return CGSizeMake(newWidth, newHeight);
}

@implementation WMFCardViewController

#pragma mark - Class Methods

+ (NSString*)nibnameForCardType:(WMFCardType)type {
    static NSDictionary* typeToNibMap = nil;

    if (!typeToNibMap) {
        typeToNibMap = @{
            @(WMFCardTypePrototype1): @"WMFCardViewControllerPrototype1",
            @(WMFCardTypePrototype2): @"WMFCardViewControllerPrototype2",
        };
    }
    return typeToNibMap[@(type)];
}

+ (instancetype)cardViewControllerWithType:(WMFCardType)type pageTitle:(MWKTitle*)title {
    WMFCardViewController* vc = [[[self class] alloc] initWithNibName:[[self class] nibnameForCardType:type] bundle:nil];
    vc.pageTitle = title;
    return vc;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.requestManager = [AFHTTPRequestOperationManager wmf_apiRequestManagerWithResponseSerializers:
                           @[[MWKArticlePreviewResponseSerializer serializer]]];

    self.imageResponseSerializer = [AFImageResponseSerializer serializer];

    self.articleTitle.font        = cardTitleFont();
    self.wikidataDescription.font = cardDescriptionFont();
    self.summary.font             = cardSummaryFont();

    self.imageViewBackground.backgroundColor = cardImageBackgroundColor();
    self.imageView.alpha                     = 0.0;
    self.imageTIntView.backgroundColor       = cardImageTintColor();
    self.imageTIntView.alpha                 = 0.0;
    self.wikidataDescription.alpha           = 0.0;
    self.summary.alpha                       = 0.0;

    self.articleTitle.text = self.pageTitle.text ? : [LoremIpsum title];
    ;

    if (cardLoremIpsumEnabled()) {
        [self updateUIWithLoremIpsum];
    } else {
        [self getArticlePreviewForPageTitle:self.pageTitle];
    }
}

- (void)updateUIWithPreview:(MWKArticlePreview*)preview {
    self.wikidataDescription.text = preview.pageDescription;
    self.summary.text             = preview.pageSnippet;

    [UIView animateWithDuration:0.3 animations:^{
        self.wikidataDescription.alpha = 1.0;
        self.summary.alpha = 1.0;
    }];

    if (preview.thumbnailURL) {
        NSURL* imageURL = [NSURL URLWithString:preview.thumbnailURL];

        [self getImageWithURL:imageURL completion:^(UIImage* image) {
            if (cardImageBlur()) {
                image = [image applyBlurWithRadius:cardImageBlurRadius() tintColor:nil saturationDeltaFactor:1.8 maskImage:nil];
            }

            image = [image scaleToSize:self.imageView.bounds.size usingMode:NYXResizeModeAspectFill];

            //I know this is the big image
            if (self.wikidataDescription) {
                self.imageView.layer.transform = CATransform3DMakeScale(cardImageFadeScaleEffect(), cardImageFadeScaleEffect(), 1.0);

//                UIColor* imageColor = [image averageColor];
//                CGFloat distanceFromWhite = [[UIColor whiteColor] distanceFromColor:imageColor type:ColorDistanceCIE2000];

                UIColor* textColor = nil;
                UIColor* imageTintColor = nil;

//                CGFloat maxDistanceFromWhite = cardImageDistanceFromWhite();
//
//                if(distanceFromWhite <= maxDistanceFromWhite){

//                textColor = [UIColor blackColor];
//                imageTintColor = cardImageLightTintColor();

//                }else{
//
                textColor = [UIColor whiteColor];
                imageTintColor = cardImageDarkTintColor();
//                }

                self.imageTIntView.backgroundColor = imageTintColor;

                [UIView transitionWithView:self.articleTitle
                                  duration:cardImageFadeDuraton()
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                    self.articleTitle.textColor = textColor;
                }
                                completion:nil];

                [UIView transitionWithView:self.wikidataDescription
                                  duration:cardImageFadeDuraton()
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                    self.wikidataDescription.textColor = textColor;
                }
                                completion:nil];

                [UIView transitionWithView:self.summary
                                  duration:cardImageFadeDuraton()
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                    self.summary.textColor = textColor;
                }
                                completion:nil];
            }

            self.imageView.image = image;

            [UIView animateWithDuration:cardImageFadeDuraton() animations:^{
                self.imageView.alpha = 1.0;
                self.imageTIntView.alpha = 1.0;
                self.imageView.layer.transform = CATransform3DIdentity;
            }];
        }];
    }
}

- (void)updateUIWithLoremIpsum {
    self.wikidataDescription.text = [LoremIpsum sentence];
    self.summary.text             = [LoremIpsum paragraph];

    [UIView animateWithDuration:0.3 animations:^{
        self.wikidataDescription.alpha = 1.0;
        self.summary.alpha = 1.0;
    }];

    [LoremIpsum asyncPlaceholderImageFromService:LIPlaceholderImageServiceLoremPixel withSize:CGSizeMake(self.imageView.bounds.size.width, self.imageView.bounds.size.height)  completion:^(UIImage* image) {
        if (cardImageBlur()) {
            image = [image applyBlurWithRadius:cardImageBlurRadius() tintColor:nil saturationDeltaFactor:1.8 maskImage:nil];
        }

        //I know this is the big image
        if (self.wikidataDescription) {
            self.imageView.layer.transform = CATransform3DMakeScale(cardImageFadeScaleEffect(), cardImageFadeScaleEffect(), 1.0);

//            UIColor* imageColor = [image averageColor];
//            CGFloat distanceFromWhite = [imageColor distanceFromColor:[UIColor whiteColor]];

            UIColor* textColor = nil;
            UIColor* imageTintColor = nil;

            textColor = [UIColor whiteColor];
            imageTintColor = cardImageDarkTintColor();

            self.imageTIntView.backgroundColor = imageTintColor;

            [UIView transitionWithView:self.articleTitle
                              duration:cardImageFadeDuraton()
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                self.articleTitle.textColor = textColor;
            }
                            completion:nil];

            [UIView transitionWithView:self.wikidataDescription
                              duration:cardImageFadeDuraton()
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                self.wikidataDescription.textColor = textColor;
            }
                            completion:nil];

            [UIView transitionWithView:self.summary
                              duration:cardImageFadeDuraton()
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                self.summary.textColor = textColor;
            }
                            completion:nil];
        }

        self.imageView.image = image;

        [UIView animateWithDuration:cardImageFadeDuraton() animations:^{
            self.imageView.alpha = 1.0;
            self.imageTIntView.alpha = 1.0;
            self.imageView.layer.transform = CATransform3DIdentity;
        }];
    }];
}

#pragma msrk - Networking

- (void)getArticlePreviewForPageTitle:(MWKTitle*)pageTitle {
    if (!pageTitle) {
        return;
    }

    WMFApiRequestParameters* requestForPreview =
        [WMFApiRequestParameters articlePreviewParametersForTitle:pageTitle.prefixedText];

    __weak __typeof__(self) weakSelf = self;
    [self.requestManager
     wmf_idempotentGET:[[SessionSingleton sharedInstance] urlForLanguage:pageTitle.site.language].absoluteString
            parameters:[requestForPreview  httpQueryParameterDictionary]
               success:^(AFHTTPRequestOperation* response, MWKArticlePreview* articlePreview) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateUIWithPreview:articlePreview];
        });
    }
               failure:NULL];
}

+ (NSOperationQueue*)sharedImageRequestOperationQueue {
    static NSOperationQueue* sharedImageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedImageRequestOperationQueue = [[NSOperationQueue alloc] init];
        sharedImageRequestOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });

    return sharedImageRequestOperationQueue;
}

//Take from UIImage+AFNetworking and then modified
- (void)getImageWithURL:(NSURL*)url completion:(void (^)(UIImage* image))completion {
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    __weak __typeof(self) weakSelf                = self;
    self.imageRequestOperation                    = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.imageRequestOperation.responseSerializer = self.imageResponseSerializer;
    [self.imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if ([[request URL] isEqual:[strongSelf.imageRequestOperation.request URL]]) {
            if (completion) {
                completion(responseObject);
            }

            if (operation == strongSelf.imageRequestOperation) {
                strongSelf.imageRequestOperation = nil;
            }
        }
    } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if ([[request URL] isEqual:[strongSelf.imageRequestOperation.request URL]]) {
            if (operation == strongSelf.imageRequestOperation) {
                strongSelf.imageRequestOperation = nil;
            }
        }
    }];

    [[[self class] sharedImageRequestOperationQueue] addOperation:self.imageRequestOperation];
}

@end
