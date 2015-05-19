//
//  MWKHistoryList.h
//  MediaWikiKit
//
//  Created by Brion on 11/17/14.
//  Copyright (c) 2014 Wikimedia Foundation. All rights reserved.
//

#import "MediaWikiKit.h"
#import <Bolts/Bolts.h>

@class MWKTitle;
@class MWKHistoryEntry;
@class MWKDataStore;

@interface MWKHistoryList : MWKDataObject <NSFastEnumeration>

@property (readonly, weak, nonatomic) MWKDataStore* dataStore;
@property (nonatomic, readonly, assign) NSUInteger length;
@property (nonatomic, readwrite, assign) BOOL dirty;
@property (nonatomic, readonly, strong) MWKHistoryEntry* mostRecentEntry;

/**
 *  Create history list and connect with data store.
 *  Will import any saved data from the data store on initialization
 *
 *  @param dataStore The data store to use for retrival and saving
 *
 *  @return The history list
 */
- (instancetype)initWithDataStore:(MWKDataStore*)dataStore;


- (MWKHistoryEntry*)entryAtIndex:(NSUInteger)index;
- (MWKHistoryEntry*)entryForTitle:(MWKTitle*)title;

- (NSUInteger)indexForEntry:(MWKHistoryEntry*)entry;
- (MWKHistoryEntry*)entryAfterEntry:(MWKHistoryEntry*)entry;
- (MWKHistoryEntry*)entryBeforeEntry:(MWKHistoryEntry*)entry;


/**
 *  Add a page to the user history.
 *  Calling this on a page already in the history will simply update its date.
 *
 *  @param title           The title of the page to add
 *  @param discoveryMethod The method of discovery. MWKHistoryDiscoveryMethodUnknown is ignored if updating an existing entry.
 *
 *  @return The task. The result is the MWKHistoryEntry.
 */
- (BFTask*)addPageToHistoryWithTitle:(MWKTitle*)title discoveryMethod:(MWKHistoryDiscoveryMethod)discoveryMethod;


/**
 *  Add an entry to the the user history
 *  Use this method if you needed to create an entry directly.
 *
 *  @param entry The entry to add
 *
 *  @return The task. The result is the MWKHistoryEntry.
 */
- (BFTask*)addEntry:(MWKHistoryEntry*)entry;


/**
 *  Save the scroll position of a page
 *
 *  @param scrollposition The scroll position to save
 *  @param title          The title of the page
 *
 *  @return The task. The result is the MWKHistoryEntry.
 */
- (BFTask*)savePageScrollPosition:(CGFloat)scrollposition toPageInHistoryWithTitle:(MWKTitle*)title;

/**
 *  Remove a page from the user history
 *
 *  @param title The title of the page to remove
 *
 *  @return The task. The result is nil.
 */
- (BFTask*)removePageFromHistoryWithTitle:(MWKTitle*)title;

/**
 *  Remove the given hstory entries from the history
 *
 *  @param historyEntries An array of instances of MWKHistoryEntry
 *
 *  @return The task. The result is nil.
 */
- (BFTask*)removeEntriesFromHistory:(NSArray*)historyEntries;

/**
 *  Remove all history items.
 *
 *  @return The task. The result is nil.
 */
- (BFTask*)removeAllEntriesFromHistory;

/**
 *  Save changes to data store.
 *
 *  @return The task. Result will be nil.
 */
- (BFTask*)save;



@end
