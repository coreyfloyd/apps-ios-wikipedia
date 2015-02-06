//  Created by Monte Hurd on 10/24/14.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "AboutViewController.h"
#import "WikipediaAppUtils.h"
#import "UIViewController+ModalPop.h"
#import "UIWebView+LoadAssetsHtml.h"
#import "Defines.h"
#import <BlocksKit/BlocksKit.h>
#import "ModalContentViewController.h"

static NSString* const kWMFAboutHTMLFile = @"about.html";
static NSString* const kWMFAboutPlistName = @"AboutViewController";

static NSString* const kWMFURLsKey = @"urls";
static NSString* const kWMFURLsFeedbackKey = @"feedback";
static NSString* const kWMFURLsTranslateWikiKey = @"twn";
static NSString* const kWMFURLsWikimediaKey = @"wmf";
static NSString* const kWMFURLsSpecialistGuildKey = @"tsg";

static NSString* const kWMFRepositoriesKey = @"repositories";

static NSString* const kWMFLibrariesKey = @"libraries";
static NSString* const kWMFLibraryNameKey = @"Name";
static NSString* const kWMFLibraryURLKey = @"Source URL";
static NSString* const kWMFLibraryFileNameKey = @"Licence File Name";

static NSString* const kWMFContributorsKey = @"contributors";


@interface AboutViewController ()

@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain, readonly) NSString *contributors;
@property (nonatomic, retain, readonly) NSString *repositoryLinks;
@property (nonatomic, retain, readonly) NSString *libraryLinks;
@property (nonatomic, retain, readonly) NSDictionary *urls;
@property (nonatomic, retain, readonly) NSString *feedbackURL;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:kWMFAboutPlistName ofType:@"plist"];
    self.data = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    self.webView.delegate = self;
    [self.webView loadHTMLFromAssetsFile:kWMFAboutHTMLFile];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(navItemTappedNotification:)
                                                 name: @"NavItemTapped"
                                               object: nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: @"NavItemTapped"
                                                  object: nil];
    [super viewWillDisappear:animated];
}

- (void)navItemTappedNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    UIView *tappedItem = userInfo[@"tappedItem"];
    
    switch (tappedItem.tag) {
        case NAVBAR_BUTTON_X:
            [self popModal];
            break;
        case NAVBAR_BUTTON_ARROW_LEFT:
            [self.webView loadHTMLFromAssetsFile:kWMFAboutHTMLFile];
            break;
        default:
            break;
    }
}

-(NavBarMode)navBarMode
{
    if([[[[self.webView request] URL] pathExtension] isEqualToString:@"txt"]){

        return NAVBAR_MODE_BACK_WITH_LABEL;
    }
    
    return NAVBAR_MODE_X_WITH_LABEL;
}

-(NSString *)title
{
    if([[[[self.webView request] URL] pathExtension] isEqualToString:@"txt"]){
        
        return MWLocalizedString(@"about-libraries-license", nil);
    }

    return MWLocalizedString(@"about-title", nil);
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

-(NSString *)contributors
{
    return [self.data[kWMFContributorsKey] componentsJoinedByString:@", "];
}

-(NSDictionary *)urls
{
    return self.data[kWMFURLsKey];
}

-(NSString *)libraryLinks
{
    NSArray *libraries = [self.data[kWMFLibrariesKey] bk_map:^id(NSDictionary *obj) {
        
        NSString* sourceLink = [[self class] linkHTMLForURLString:obj[kWMFLibraryURLKey] title:obj[kWMFLibraryNameKey]];
        
        NSString* filePath = [[NSBundle mainBundle] pathForResource:obj[kWMFLibraryFileNameKey] ofType:@"txt"];
        NSString* licenseLink = [[self class] linkHTMLForURLString:filePath title:MWLocalizedString(@"about-libraries-license", nil)];
        
        return [sourceLink stringByAppendingFormat:@" (%@)", licenseLink];
    }];
    
    return [libraries componentsJoinedByString:@", "];
}

-(NSString *)repositoryLinks
{
    NSMutableDictionary *repos = (NSMutableDictionary *)self.data[kWMFRepositoriesKey];
    
    for (NSString *repo in [repos copy]) {
        repos[repo] = [[self class] linkHTMLForURLString:repos[repo] title:repo];
    }
    
    NSString *output = [repos.allValues componentsJoinedByString:@", "];
    return output;
}

-(NSString *)feedbackURL
{
    NSString *feedbackUrl = self.urls[kWMFURLsFeedbackKey];
    feedbackUrl = [feedbackUrl stringByReplacingOccurrencesOfString:@"$1" withString:[WikipediaAppUtils versionedUserAgent]];

    NSString *encodedUrlString =
    [feedbackUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return encodedUrlString;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString*(^stringEscapedForJavasacript)(NSString*) = ^ NSString*(NSString *string) {
        // FROM: http://stackoverflow.com/a/13569786
        // valid JSON object need to be an array or dictionary
        NSArray *arrayForEncoding = @[string];
        NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:arrayForEncoding options:0 error:nil] encoding:NSUTF8StringEncoding];
        NSString *escapedString = [jsonString substringWithRange:NSMakeRange(2, jsonString.length - 4)];
        return escapedString;
    };
    
    void (^setDivHTML)(NSString*, NSString*) = ^ void(NSString *divId, NSString *twnString) {
        twnString = stringEscapedForJavasacript(twnString);
        [self.webView stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:@"document.getElementById('%@').innerHTML = \"%@\";", divId, twnString]];
    };
    
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *version = appInfo[@"CFBundleVersion"] ? appInfo[@"CFBundleVersion"] : @"Unknown version";
    
    setDivHTML(@"version", version);
    setDivHTML(@"wikipedia", MWLocalizedString(@"about-wikipedia", nil));
    setDivHTML(@"contributors_title", MWLocalizedString(@"about-contributors", nil));
    setDivHTML(@"contributors_body", self.contributors);
    setDivHTML(@"translators_title", MWLocalizedString(@"about-translators", nil));
    setDivHTML(@"testers_title", MWLocalizedString(@"about-testers", nil));
    setDivHTML(@"libraries_title", MWLocalizedString(@"about-libraries", nil));
    setDivHTML(@"libraries_body", self.libraryLinks);
    setDivHTML(@"repositories_title", MWLocalizedString(@"about-repositories", nil));
    setDivHTML(@"repositories_body", self.repositoryLinks);
    setDivHTML(@"feedback_body", [[self class] linkHTMLForURLString:self.feedbackURL title:MWLocalizedString(@"about-send-feedback", nil)]);
    
    NSString *twnUrl = self.urls[kWMFURLsTranslateWikiKey];
    NSString *translatorsLink = [[self class] linkHTMLForURLString:twnUrl title:[twnUrl substringFromIndex:7]];
    NSString *translatorDetails =
    [MWLocalizedString(@"about-translators-details", nil) stringByReplacingOccurrencesOfString: @"$1"
                                                                                    withString: translatorsLink];
    setDivHTML(@"translators_body", translatorDetails);
    
    NSString *tsgUrl = self.urls[kWMFURLsSpecialistGuildKey];
    NSString *tsgLink = [[self class] linkHTMLForURLString:tsgUrl title:[tsgUrl substringFromIndex:7]];
    NSString *tsgDetails =
    [MWLocalizedString(@"about-testers-details", nil) stringByReplacingOccurrencesOfString: @"$1"
                                                                                    withString: tsgLink];
    setDivHTML(@"testers_body", tsgDetails);
    
    NSString *wmfUrl = self.urls[kWMFURLsWikimediaKey];
    NSString *foundation = [[self class] linkHTMLForURLString:wmfUrl title:MWLocalizedString(@"about-wikimedia-foundation", nil)];
    NSString *footer =
    [MWLocalizedString(@"about-product-of", nil) stringByReplacingOccurrencesOfString: @"$1"
                                                                           withString: foundation];
    setDivHTML(@"footer", footer);
    
    NSString *textDirection = ([WikipediaAppUtils isDeviceLanguageRTL] ? @"rtl" : @"ltr");
    NSString *textDirectionJS = [NSString stringWithFormat:@"document.body.style.direction = '%@'", textDirection];
    [self.webView stringByEvaluatingJavaScriptFromString:textDirectionJS];

    NSString *fontSizeJS = [NSString stringWithFormat:@"document.body.style.fontSize = '%f%%'", (MENUS_SCALE_MULTIPLIER * 100.0f)];
    [self.webView stringByEvaluatingJavaScriptFromString:fontSizeJS];

    /*
     HACK: This is pretty terrible. The current VC should not need to know about the containing view controller to set its nav bar buttons and title.
     We really need to change the modal display logic to make sure modal VCs can update their navigation bar.
     That is obviously a pretty big refactor and effects several VCs - so not doing that here. In the mean time, we are casting what we know the containing VC to be so we can make the needed changes.
     */
    [(ModalContentViewController*)self.parentViewController setNavBarMode:self.navBarMode];
    [(ModalContentViewController*)self.parentViewController setTopMenuText:self.title];

}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    NSURL *requestURL = [request URL];
    
    if (
        (navigationType == UIWebViewNavigationTypeLinkClicked)
        &&
        (
         [[requestURL scheme] isEqualToString:@"http"]
         ||
         [[requestURL scheme] isEqualToString:@"https"]
         ||
         [[requestURL scheme] isEqualToString:@"mailto"])
        ) {
        return ![[UIApplication sharedApplication] openURL:requestURL];
    }
    return YES;
}

+ (NSString *)linkHTMLForURLString:(NSString *)url title:(NSString *)title
{
    return [NSString stringWithFormat:@"<a href='%@'>%@</a>", url, title];
}


@end
