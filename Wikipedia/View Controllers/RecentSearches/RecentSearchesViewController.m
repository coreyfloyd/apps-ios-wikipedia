//  Created by Monte Hurd on 11/17/14.
//  Copyright (c) 2014 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "RecentSearchesViewController.h"
#import "RecentSearchCell.h"
#import "PaddedLabel.h"
#import "NSObject+ConstraintsScale.h"
#import "WikiGlyphButton.h"
#import "WikiGlyphLabel.h"
#import "WikiGlyph_Chars.h"
#import "WikipediaAppUtils.h"
#import "NSArray+Predicate.h"
#import "TopMenuTextFieldContainer.h"
#import "TopMenuTextField.h"
#import "TopMenuViewController.h"
#import "RootViewController.h"
#import "UIViewController+HideKeyboard.h"
#import "UIView+TemporaryAnimatedXF.h"
#import "MWKUserDataStore.h"
#import "SessionSingleton.h"
#import "MWKRecentSearchList.h"
#import "MWKRecentSearchEntry.h"

#define CELL_HEIGHT (48.0 * MENUS_SCALE_MULTIPLIER)
#define HEADING_FONT_SIZE (16.0 * MENUS_SCALE_MULTIPLIER)
#define HEADING_COLOR [UIColor blackColor]
#define HEADING_PADDING UIEdgeInsetsMake(22.0f, 16.0f, 22.0f, 16.0f)
#define TRASH_FONT_SIZE (30.0 * MENUS_SCALE_MULTIPLIER)
#define TRASH_COLOR [UIColor grayColor]
#define TRASH_DISABLED_COLOR [UIColor lightGrayColor]
#define PLIST_FILE_NAME @"Recent.plist"
#define LIMIT 100

@interface RecentSearchesViewController ()

@property (weak, nonatomic) IBOutlet UITableView* table;
@property (weak, nonatomic) IBOutlet PaddedLabel* headingLabel;
@property (weak, nonatomic) IBOutlet WikiGlyphButton* trashButton;

@end

@implementation RecentSearchesViewController

- (MWKUserDataStore*)userdataStore{
    
    return [[SessionSingleton sharedInstance] userDataStore];
}

- (MWKRecentSearchList*)recentList{
    
    return [[self userdataStore] recentSearchList];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupTrashButton];
    [self setupHeadingLabel];
    [self setupTable];

    [self adjustConstraintsScaleForViews:@[self.headingLabel, self.trashButton]];

    [self updateTrashButtonEnabledState];

}

- (void)setupTable {
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.table registerNib:[UINib nibWithNibName:@"RecentSearchCell" bundle:nil] forCellReuseIdentifier:@"RecentSearchCell"];
}

- (void)setupHeadingLabel {
    self.headingLabel.padding   = HEADING_PADDING;
    self.headingLabel.font      = [UIFont boldSystemFontOfSize:HEADING_FONT_SIZE];
    self.headingLabel.textColor = HEADING_COLOR;
    self.headingLabel.text      = MWLocalizedString(@"search-recent-title", nil);
}

- (void)setupTrashButton {
    self.trashButton.backgroundColor = [UIColor clearColor];
    [self.trashButton.label setWikiText:WIKIGLYPH_TRASH color:TRASH_COLOR
                                   size:TRASH_FONT_SIZE
                         baselineOffset:1];

    self.trashButton.accessibilityLabel  = MWLocalizedString(@"menu-trash-accessibility-label", nil);
    self.trashButton.accessibilityTraits = UIAccessibilityTraitButton;

    [self.trashButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(trashButtonTapped)]];
}

- (void)reloadTable{
    
    [self.table reloadData];
    [self updateTrashButtonEnabledState];
}

- (void)updateTrashButtonEnabledState {
    self.trashButton.enabled = ([[self recentList] length] > 0) ? YES : NO;
}

- (void)removeEntry:(MWKRecentSearchEntry*)entry{
    [[[self userdataStore] recentSearchList] removeEntry:entry];
    [[self userdataStore] save];
}

- (void)removeAllTerms {
    [[self recentList] removeAllEntries];
    [[self userdataStore] save];
}

- (void)trashButtonTapped {
    if (!self.trashButton.enabled) {
        return;
    }

    [self.trashButton animateAndRewindXF:CATransform3DMakeScale(1.2f, 1.2f, 1.0f)
                              afterDelay:0.0
                                duration:0.1
                                    then:^{
        [self showDeleteAllDialog];
    }];
}

- (void)showDeleteAllDialog {
    UIAlertView* dialog =
        [[UIAlertView alloc] initWithTitle:MWLocalizedString(@"search-recent-clear-confirmation-heading", nil)
                                   message:MWLocalizedString(@"search-recent-clear-confirmation-sub-heading", nil)
                                  delegate:self
                         cancelButtonTitle:MWLocalizedString(@"search-recent-clear-cancel", nil)
                         otherButtonTitles:MWLocalizedString(@"search-recent-clear-delete-all", nil), nil];
    [dialog show];
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex != buttonIndex) {
        [self deleteAllRecentSearchItems];
    }
}

- (void)deleteAllRecentSearchItems {
    [self removeAllTerms];
    [self updateTrashButtonEnabledState];
    [self reloadTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self recentList] length];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    static NSString* cellId = @"RecentSearchCell";
    RecentSearchCell* cell  = (RecentSearchCell*)[tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];

    NSString* term = [[[self recentList] entryAtIndex:indexPath.row] searchTerm];
    [cell.label setText:term];

    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeEntry:[[self recentList] entryAtIndex:indexPath.row]];

        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self updateTrashButtonEnabledState];
    }
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    TopMenuTextFieldContainer* textFieldContainer =
        [ROOT.topMenuViewController getNavBarItem:NAVBAR_TEXT_FIELD];

    NSString* term = [[[self recentList] entryAtIndex:indexPath.row] searchTerm];
    textFieldContainer.textField.text = term;

    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell animateAndRewindXF:CATransform3DMakeScale(1.025f, 1.0f, 1.0f)
                  afterDelay:0.0
                    duration:0.1
                        then:^{
        [textFieldContainer.textField sendActionsForControlEvents:UIControlEventEditingChanged];
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView {
    [self hideKeyboard];
}

@end
