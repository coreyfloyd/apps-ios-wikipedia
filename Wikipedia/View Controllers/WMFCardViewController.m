
#import "WMFCardViewController.h"
#import <LoremIpsum/LoremIpsum.h>
#import "WMFCardHelpers.h"
#import <Colours/Colours.h>
#import <UIImage+AverageColor/UIImage+AverageColor.h>
#import "UIImage+ImageEffects.h"
#import "UIView+SnapShot.h"

@interface WMFCardViewController ()

@property (nonatomic, assign, readwrite) WMFCardType type;


@end

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

+ (instancetype)cardViewControllerWithType:(WMFCardType)type {
    return [[[self class] alloc] initWithNibName:[[self class] nibnameForCardType:type] bundle:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.articleTitle.font        = [UIFont boldSystemFontOfSize:cardTitleFontSize()];
    self.wikidataDescription.font = [UIFont boldSystemFontOfSize:cardDescriptionFontSize()];
    self.summary.font             = [UIFont systemFontOfSize:cardSummaryFontSize()];

    self.articleTitle.text                   = [LoremIpsum title];
    self.wikidataDescription.text            = [LoremIpsum sentence];
    self.summary.text                        = [LoremIpsum paragraph];
    self.imageViewBackground.backgroundColor = cardImageBackgroundColor();
    self.imageView.alpha                     = 0.0;
    self.imageTIntView.backgroundColor       = cardImageTintColor();
    self.imageTIntView.alpha                 = 0.0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [LoremIpsum asyncPlaceholderImageFromService:LIPlaceholderImageServiceLoremPixel withSize:CGSizeMake(self.imageView.bounds.size.width, self.imageView.bounds.size.height)  completion:^(UIImage* image) {
        if (cardImageBlur()) {
            image = [image applyBlurWithRadius:cardbackgroundBlurRadius() tintColor:nil saturationDeltaFactor:1.8 maskImage:nil];
        }

        //I know this is the big image
        if (self.wikidataDescription) {
            self.imageView.layer.transform = CATransform3DMakeScale(0.95, 0.95, 1.0);

            UIColor* imageColor = [image averageColor];
            UIColor* textColor = [imageColor blackOrWhiteContrastingColor];
            UIColor* imageTintColor = [[textColor blackOrWhiteContrastingColor] colorWithAlphaComponent:[self.imageTIntView.backgroundColor alpha]];
            self.imageTIntView.backgroundColor = imageTintColor;

            [UIView transitionWithView:self.articleTitle
                              duration:0.25
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                self.articleTitle.textColor = textColor;
            }
                            completion:nil];

            [UIView transitionWithView:self.wikidataDescription
                              duration:0.25
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                self.wikidataDescription.textColor = textColor;
            }
                            completion:nil];

            [UIView transitionWithView:self.summary
                              duration:0.25
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                self.summary.textColor = textColor;
            }
                            completion:nil];
        }

        self.imageView.image = image;

        [UIView animateWithDuration:0.25 animations:^{
            self.imageView.alpha = 1.0;
            self.imageTIntView.alpha = 1.0;
            self.imageView.layer.transform = CATransform3DIdentity;
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
   #pragma mark - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
   }
 */

@end
