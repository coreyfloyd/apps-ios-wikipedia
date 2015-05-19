//
//  MWKRecentSearchList.m
//  MediaWikiKit
//
//  Created by Brion on 11/18/14.
//  Copyright (c) 2014 Wikimedia Foundation. All rights reserved.
//

#import "MediaWikiKit.h"

@interface MWKRecentSearchList ()

@property (readwrite, weak, nonatomic) MWKDataStore* dataStore;
@property (readwrite, nonatomic, assign) NSUInteger length;
@property (readwrite, nonatomic, assign) BOOL dirty;
@property (nonatomic, strong) NSMutableArray* entries;

@end

@implementation MWKRecentSearchList

#pragma mark - Setup

- (instancetype)initWithDataStore:(MWKDataStore*)dataStore {
    self = [super init];
    if (self) {
        self.dataStore = dataStore;
        self.entries   = [[NSMutableArray alloc] init];
        NSDictionary* data = [self.dataStore historyListData];
        [self importData:data];
    }
    return self;
}

#pragma mark - Data methods

- (void)importData:(NSDictionary*)data {
    for (NSDictionary* entryDict in data[@"entries"]) {
        MWKRecentSearchEntry* entry = [[MWKRecentSearchEntry alloc] initWithDict:entryDict];
        [self.entries addObject:entry];
    }
    self.dirty = NO;
}

- (id)dataExport {
    NSMutableArray* dicts = [[NSMutableArray alloc] init];
    for (MWKRecentSearchEntry* entry in self.entries) {
        [dicts addObject:[entry dataExport]];
    }
    return @{@"entries": dicts};
}

#pragma mark - Data Update

- (BFTask*)addEntry:(MWKRecentSearchEntry*)entry {
    if (entry.searchTerm == nil) {
        return [BFTask taskWithError:nil];
    }

    NSUInteger oldIndex = [self.entries indexOfObject:entry];
    if (oldIndex != NSNotFound) {
        // Move to top!
        [self.entries removeObjectAtIndex:oldIndex];
    }
    [self.entries insertObject:entry atIndex:0];
    self.dirty = YES;
    // @todo trim to max?

    return [BFTask taskWithResult:entry];
}

#pragma mark - Entry Access

- (MWKRecentSearchEntry*)entryAtIndex:(NSUInteger)index {
    return self.entries[index];
}

#pragma mark - Save

- (BFTask*)save {
    NSError* error;
    if (self.dirty && ![self.dataStore saveRecentSearchList:self error:&error]) {
        NSAssert(NO, @"Error saving saved pages: %@", [error localizedDescription]);
        return [BFTask taskWithError:error];
    } else {
        self.dirty = NO;
    }

    return [BFTask taskWithResult:nil];
}

@end
