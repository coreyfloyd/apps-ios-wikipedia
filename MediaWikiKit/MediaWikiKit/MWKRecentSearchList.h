//
//  MWKRecentSearchList.h
//  MediaWikiKit
//
//  Created by Brion on 11/18/14.
//  Copyright (c) 2014 Wikimedia Foundation. All rights reserved.
//

#import "MWKDataObject.h"
#import <Bolts/Bolts.h>

@class MWKRecentSearchEntry;

@interface MWKRecentSearchList : MWKDataObject

@property (readonly, weak, nonatomic) MWKDataStore* dataStore;
@property (readonly, nonatomic, assign) NSUInteger length;
@property (readonly, nonatomic, assign) BOOL dirty;

/**
 *  Create saved page list and connect with data store.
 *  Will import any saved data from the data store on initialization
 *
 *  @param dataStore The data store to use for retrival and saving
 *
 *  @return The saved page list
 */
- (instancetype)initWithDataStore:(MWKDataStore*)dataStore;

- (MWKRecentSearchEntry*)entryAtIndex:(NSUInteger)index;

/**
 *  Add an entry to the search history
 *
 *  @param entry The entry to add
 *
 *  @return The task. The result is the MWKSavedPageEntry.
 */
- (BFTask*)addEntry:(MWKRecentSearchEntry*)entry;

/**
 *  Save changes to data store.
 *
 *  @return The task. Result will be nil.
 */
- (BFTask*)save;

@end
