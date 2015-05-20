//  Created by Monte Hurd on 12/4/13.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "SavedPagesViewController.h"
#import "WikipediaAppUtils.h"
#import "WebViewController.h"
#import "SavedPagesResultCell.h"
#import "Defines.h"
#import "SessionSingleton.h"
#import "CenterNavController.h"
#import "NSString+Extras.h"
#import "TopMenuContainerView.h"
#import "UIViewController+StatusBarHeight.h"
#import "UIViewController+ModalPop.h"
#import "MenuButton.h"
#import "TopMenuViewController.h"
#import "DataHousekeeping.h"
#import "SavedPagesFunnel.h"
#import "NSObject+ConstraintsScale.h"
#import "PaddedLabel.h"
#import "QueuesSingleton.h"
#import "SavedArticlesFetcher.h"
#import "WMFBorderButton.h"
#import "WMFProgressLineView.h"
#import <Masonry/Masonry.h>
#import "NSAttributedString+WMFSavedPagesAttributedStrings.h"
#import "UITableView+DynamicCellHeight.h"

static NSString* const kSavedPagesDidShowCancelRefreshAlert = @"WMFSavedPagesDidShowCancelRefreshAlert";
static NSString* const kSavedPagesCellID                    = @"SavedPagesResultCell";

@interface SavedPagesViewController ()<SavedArticlesFetcherDelegate>

@property (strong, nonatomic) IBOutlet UITableView* tableView;

@property (strong, nonatomic) SavedPagesFunnel* funnel;

@property (strong, nonatomic) IBOutlet UIImageView* emptyImage;
@property (strong, nonatomic) IBOutlet PaddedLabel* emptyTitle;
@property (strong, nonatomic) IBOutlet PaddedLabel* emptyDescription;

@property (strong, nonatomic) IBOutlet UIView* emptyContainerView;

@property (strong, nonatomic) WMFProgressLineView* progressView;
@property (strong, nonatomic) WMFBorderButton* cancelButton;

@property (strong, nonatomic) MWKUserDataStore* userDataStore;
@property (strong, nonatomic, readonly) MWKSavedPageList* savedPageList;

@property (strong, nonatomic) SavedPagesResultCell* offScreenSizingCell;

@property (strong, nonatomic) UIImage* placeholderThumbnailImage;

@end

@implementation SavedPagesViewController

#pragma mark - Accessors

- (MWKSavedPageList*)savedPageList {
    return self.userDataStore.savedPageList;
}

#pragma mark - NavBar

- (NavBarMode)navBarMode {
    return NAVBAR_MODE_PAGES_SAVED;
}

- (NSString*)title {
    return MWLocalizedString(@"saved-pages-title", nil);
}

- (MenuButton*)reloadButton {
    return (MenuButton*)[self.topMenuViewController getNavBarItem:NAVBAR_BUTTON_RELOAD];
}

- (WMFBorderButton*)cancelButton {
    if (!_cancelButton) {
        WMFBorderButton* button = [WMFBorderButton standardBorderButton];
        [button setTitle:MWLocalizedString(@"saved-pages-clear-cancel", nil) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(cancelRefresh) forControlEvents:UIControlEventTouchUpInside];

        _cancelButton = button;
    }

    return _cancelButton;
}

- (WMFProgressLineView*)progressView {
    if (!_progressView) {
        WMFProgressLineView* progress = [[WMFProgressLineView alloc] initWithFrame:CGRectZero];
        _progressView = progress;
    }

    return _progressView;
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Top menu

// Handle nav bar taps. (same way as any other view controller would)
- (void)navItemTappedNotification:(NSNotification*)notification {
    NSDictionary* userInfo = [notification userInfo];
    UIView* tappedItem     = userInfo[@"tappedItem"];

    switch (tappedItem.tag) {
        case NAVBAR_BUTTON_X:
            [self popModal];
        case NAVBAR_LABEL:
            break;
        case NAVBAR_BUTTON_RELOAD:
            [self startRefresh];
            break;
        case NAVBAR_BUTTON_TRASH:
            [self showDeleteAllDialog];
            break;
        default:
            break;
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - UIViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"NavItemTapped"
                                                  object:nil];
    self.tableView.editing = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Listen for nav bar taps.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(navItemTappedNotification:)
                                                 name:@"NavItemTapped"
                                               object:nil];

    SavedArticlesFetcher* fetcher = [SavedArticlesFetcher sharedInstance];

    if (fetcher) {
        [self resumeRefresh];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.userDataStore = [SessionSingleton sharedInstance].userDataStore;

    self.funnel = [[SavedPagesFunnel alloc] init];

    self.navigationItem.hidesBackButton = YES;

    self.tableView.contentInset = UIEdgeInsetsMake(4.0f * MENUS_SCALE_MULTIPLIER, 0, 4.0f * MENUS_SCALE_MULTIPLIER, 0);

    // Register the Saved Pages results cell for reuse
    [self.tableView registerNib:[UINib nibWithNibName:@"SavedPagesResultPrototypeView" bundle:nil] forCellReuseIdentifier:kSavedPagesCellID];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self setEmptyOverlayAndTrashIconVisibility];

    [self adjustConstraintsScaleForViews:@[self.emptyImage, self.emptyTitle, self.emptyDescription, self.emptyContainerView]];

    self.emptyTitle.font       = [UIFont boldSystemFontOfSize:17.0 * MENUS_SCALE_MULTIPLIER];
    self.emptyDescription.font = [UIFont systemFontOfSize:14.0 * MENUS_SCALE_MULTIPLIER];

    // Single off-screen cell for determining dynamic cell height.
    self.offScreenSizingCell = (SavedPagesResultCell*)[self.tableView dequeueReusableCellWithIdentifier:kSavedPagesCellID];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return self.savedPageList.length;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    SavedPagesResultCell* cell = (SavedPagesResultCell*)[tableView dequeueReusableCellWithIdentifier:kSavedPagesCellID];

    MWKArticle* article = [self articleForIndexPath:indexPath];
    [self updateViewsInCell:cell forIndexPath:indexPath withArticle:article];

    MWKImage* thumb = [article.thumbnail largestCachedVariant];

    if (thumb) {
        cell.imageView.image = [thumb asUIImage];
        cell.useField        = YES;
        return cell;
    }

    cell.imageView.image = self.placeholderThumbnailImage;
    cell.useField        = NO;

    return cell;
}

- (UIImage*)placeholderThumbnailImage {
    if (!_placeholderThumbnailImage) {
        _placeholderThumbnailImage = [UIImage imageNamed:@"logo-placeholder-saved.png"];
    }
    return _placeholderThumbnailImage;
}

- (NSAttributedString*)getAttributedStringForArticle:(MWKArticle*)article {
    return [NSAttributedString wmf_attributedStringWithTitle:article.title.prefixedText
                                                 description:article.entityDescription
                                                    language:[WikipediaAppUtils domainNameForCode:article.site.language]];
}

- (MWKArticle*)articleForIndexPath:(NSIndexPath*)indexPath {
    MWKSavedPageEntry* savedEntry = [self.savedPageList entryAtIndex:indexPath.row];
    return [self.userDataStore.dataStore articleWithTitle:savedEntry.title];
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    // Update the sizing cell with any data which could change the cell height.
    [self updateViewsInCell:self.offScreenSizingCell forIndexPath:indexPath];
    // Determine height for the current configuration of the sizing cell.
    return [tableView heightForSizingCell:self.offScreenSizingCell];
}

- (void)updateViewsInCell:(SavedPagesResultCell*)cell forIndexPath:(NSIndexPath*)indexPath {
    [self updateViewsInCell:cell forIndexPath:indexPath withArticle:[self articleForIndexPath:indexPath]];
}

- (void)updateViewsInCell:(SavedPagesResultCell*)cell
             forIndexPath:(NSIndexPath*)indexPath
              withArticle:(MWKArticle*)article {
    // Update the sizing cell with any data which could change the cell height.
    cell.savedItemLabel.attributedText = [self getAttributedStringForArticle:article];
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath {
    return YES;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.tableView.editing = NO;
        [self performSelector:@selector(deleteSavedPageForIndexPath:) withObject:indexPath afterDelay:0.15f];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    MWKSavedPageEntry* savedEntry = [self.savedPageList entryAtIndex:indexPath.row];

    [NAV loadArticleWithTitle:savedEntry.title
                     animated:YES
              discoveryMethod:MWKHistoryDiscoveryMethodSaved
                   popToWebVC:NO];

    [self popModalToRoot];
}

#pragma mark - UI Updates

- (void)showCancelButton {
    self.cancelButton.alpha = 1.0;
    [self.topMenuViewController.view addSubview:self.cancelButton];

    MenuButton* reloadButton = [self reloadButton];

    [self.cancelButton mas_remakeConstraints:^(MASConstraintMaker* make) {
        make.right.equalTo(reloadButton.mas_right);
        make.centerY.equalTo(reloadButton.mas_centerY);
    }];
}

- (void)hideCancelButton {
    self.cancelButton.alpha = 0.0;
}

- (void)showRefreshButton {
    MenuButton* reloadButton = [self reloadButton];
    reloadButton.alpha = 1.0;
}

- (void)hideRefreshButton {
    MenuButton* reloadButton = [self reloadButton];
    reloadButton.clipsToBounds = NO;
    reloadButton.alpha         = 0.0;
}

- (void)showRefreshTitle {
    UILabel* textFieldContainer = [self.topMenuViewController getNavBarItem:NAVBAR_LABEL];
    textFieldContainer.text = @"Updating";
}

- (void)hideRefreshTitle {
    UILabel* textFieldContainer = [self.topMenuViewController getNavBarItem:NAVBAR_LABEL];
    textFieldContainer.text = self.title;
}

- (void)showProgressView {
    self.progressView.alpha = 1.0;
    [self.topMenuViewController.view addSubview:self.progressView];

    [self.progressView mas_remakeConstraints:^(MASConstraintMaker* make) {
        make.top.equalTo(self.topMenuViewController.view.mas_bottom);
        make.left.equalTo(self.topMenuViewController.view.mas_left);
        make.right.equalTo(self.topMenuViewController.view.mas_right);
        make.height.equalTo(@2.0);
    }];
}

- (void)hideProgressView {
    self.progressView.alpha = 0.0;
}

- (void)hideTrashButton {
    MenuButton* trashButton = (MenuButton*)[self.topMenuViewController getNavBarItem:NAVBAR_BUTTON_TRASH];
    trashButton.alpha = 0.0;
}

- (void)showTrashButton {
    MenuButton* trashButton = (MenuButton*)[self.topMenuViewController getNavBarItem:NAVBAR_BUTTON_TRASH];
    trashButton.alpha = 1.0;
}

- (void)setEmptyOverlayAndTrashIconVisibility {
    BOOL savedPageFound = (self.savedPageList.length > 0);

    self.emptyOverlay.hidden = savedPageFound;

    MenuButton* reloadButton = [self reloadButton];
    reloadButton.alpha = savedPageFound ? 1.0 : 0.0;

    if (savedPageFound) {
        [self showTrashButton];
    } else {
        [self hideTrashButton];
    }
}

- (void)showCancelRefreshAlertIfFirstTime {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    BOOL didShowAlert = [defaults boolForKey:kSavedPagesDidShowCancelRefreshAlert];

    if (!didShowAlert) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:MWLocalizedString(@"saved-pages-refresh-cancel-alert-title", nil) message:MWLocalizedString(@"saved-pages-refresh-cancel-alert-message", nil) delegate:nil cancelButtonTitle:MWLocalizedString(@"saved-pages-refresh-cancel-alert-button", nil) otherButtonTitles:nil];

        [alert show];

        [defaults setBool:YES forKey:kSavedPagesDidShowCancelRefreshAlert];
    }
}

#pragma mark - Delete

- (void)deleteSavedPageForIndexPath:(NSIndexPath*)indexPath {
    MWKSavedPageEntry* savedEntry = [self.savedPageList entryAtIndex:indexPath.row];
    if (savedEntry) {
        [[[self.userDataStore.savedPageList removeSavedPageWithTitle:savedEntry.title] continueWithSuccessBlock:^id (BFTask* task) {
            return [self.userDataStore.savedPageList save];
        }] continueWithSuccessBlock:^id (BFTask* task) {
            // Remove any orphaned images.
            DataHousekeeping* dataHouseKeeping = [[DataHousekeeping alloc] init];
            [dataHouseKeeping performHouseKeeping];

            [self.tableView beginUpdates];

            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

            [self.tableView endUpdates];

            [self setEmptyOverlayAndTrashIconVisibility];

            [self.funnel logDelete];

            return nil;
        }];
    }
}

- (void)deleteAllSavedPages {
    [[[self.userDataStore.savedPageList removeAllSavedPages] continueWithSuccessBlock:^id (BFTask* task) {
        return [self.userDataStore.savedPageList save];
    }] continueWithSuccessBlock:^id (BFTask* task) {
        [self.tableView reloadData];

        [self setEmptyOverlayAndTrashIconVisibility];

        // Remove any orphaned images.
        DataHousekeeping* dataHouseKeeping = [[DataHousekeeping alloc] init];
        [dataHouseKeeping performHouseKeeping];

        return nil;
    }];
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex != buttonIndex) {
        [self deleteAllSavedPages];
    }
}

- (void)showDeleteAllDialog {
    UIAlertView* dialog =
        [[UIAlertView alloc] initWithTitle:MWLocalizedString(@"saved-pages-clear-confirmation-heading", nil)
                                   message:MWLocalizedString(@"saved-pages-clear-confirmation-sub-heading", nil)
                                  delegate:self
                         cancelButtonTitle:MWLocalizedString(@"saved-pages-clear-cancel", nil)
                         otherButtonTitles:MWLocalizedString(@"saved-pages-clear-delete-all", nil), nil];
    [dialog show];
}

#pragma mark - Refresh

- (void)startRefresh {
    [[QueuesSingleton sharedInstance].savedPagesFetchManager.operationQueue cancelAllOperations];

    SavedArticlesFetcher* fetcher = [[SavedArticlesFetcher alloc] initAndFetchArticlesForSavedPageList:self.savedPageList inDataStore:self.userDataStore.dataStore withManager:[QueuesSingleton sharedInstance].savedPagesFetchManager thenNotifyDelegate:self];

    [SavedArticlesFetcher setSharedInstance:fetcher];

    self.progressView.progress = 0.0;

    [UIView animateWithDuration:0.25 animations:^{
        [self hideRefreshButton];
        [self showProgressView];
        [self showRefreshTitle];
        [self hideTrashButton];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            [self showCancelButton];
        }];
    }];
}

- (void)resumeRefresh {
    [[SavedArticlesFetcher sharedInstance] getProgress:^(CGFloat progress) {
        if (progress < 100) {
            self.progressView.progress = progress;
            [SavedArticlesFetcher sharedInstance].fetchFinishedDelegate = self;

            [self showProgressView];
            [self showCancelButton];
            [self hideTrashButton];
            [self hideRefreshButton];
            [self showRefreshTitle];
        }
    }];
}

- (void)finishRefresh {
    [SavedArticlesFetcher sharedInstance].fetchFinishedDelegate = nil;
    [SavedArticlesFetcher setSharedInstance:nil];

    [UIView animateWithDuration:0.25 delay:0.5 options:0 animations:^{
        [self hideProgressView];
        [self hideCancelButton];
        [self hideRefreshTitle];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            [self showRefreshButton];
            if (self.savedPageList.length > 0) {
                [self showTrashButton];
            }
        }];

        self.progressView.progress = 0.0;
    }];
}

- (void)cancelRefresh {
    [[QueuesSingleton sharedInstance].savedPagesFetchManager.operationQueue cancelAllOperations];

    [self finishRefresh];

    [self showCancelRefreshAlertIfFirstTime];
}

#pragma mark - SavedArticlesFetcherDelegate

- (void)savedArticlesFetcher:(SavedArticlesFetcher*)savedArticlesFetcher didFetchArticle:(MWKArticle*)article progress:(CGFloat)progress status:(FetchFinalStatus)status error:(NSError*)error {
    [self.progressView setProgress:progress animated:YES];
}

- (void)fetchFinished:(id)sender fetchedData:(id)fetchedData status:(FetchFinalStatus)status error:(NSError*)error {
    __weak __typeof(self) weakSelf = self;

    [self.progressView setProgress:1.0 animated:YES completion:^{
        __typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf finishRefresh];
    }];
}

@end
