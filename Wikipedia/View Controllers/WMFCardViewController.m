
#import "WMFCardViewController.h"
#import <LoremIpsum/LoremIpsum.h>
#import "WMFCardHelpers.h"

@interface WMFCardViewController ()

@property (nonatomic, assign, readwrite) WMFCardType type;


@end

@implementation WMFCardViewController

#pragma mark - Class Methods

+ (NSString*)nibnameForCardType:(WMFCardType)type{
    
    static NSDictionary* typeToNibMap = nil;

    if(!typeToNibMap){
        
        typeToNibMap = @{
                         @(WMFCardTypePrototype1) : @"WMFCardViewControllerPrototype1",
                         @(WMFCardTypePrototype2) : @"WMFCardViewControllerPrototype2",
                         };
    }
    
    return typeToNibMap[@(type)];
}

+ (instancetype)cardViewControllerWithType:(WMFCardType)type{
    
    return [[[self class] alloc] initWithNibName:[[self class] nibnameForCardType:type] bundle:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.articleTitle.font = [UIFont systemFontOfSize:cardTitleFontSize()];
    self.wikidataDescription.font = [UIFont systemFontOfSize:cardDescriptionFontSize()];
    self.summary.font = [UIFont systemFontOfSize:cardSummaryFontSize()];
    
    self.articleTitle.text = [LoremIpsum title];
    self.wikidataDescription.text = [LoremIpsum sentence];
    self.summary.text = [LoremIpsum paragraph];
}

- (void)viewDidLayoutSubviews{
    
    [super viewDidLayoutSubviews];
 
    if(!self.imageView.image){
        self.imageView.image = [LoremIpsum placeholderImageWithSize:self.imageView.bounds.size];
    }    
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
