//
//  MWKSavedPageList.m
//  MediaWikiKit
//
//  Created by Brion on 11/3/14.
//  Copyright (c) 2014 Wikimedia Foundation. All rights reserved.
//

#import "MediaWikiKit.h"

@interface MWKSavedPageList ()

@property (readwrite, weak, nonatomic) MWKDataStore* dataStore;
@property (nonatomic, strong) NSMutableArray* entries;
@property (nonatomic, strong) NSMutableDictionary* entriesByTitle;
@property (readwrite, nonatomic, assign) BOOL dirty;

@end

@implementation MWKSavedPageList

#pragma mark - Setup

- (instancetype)initWithDataStore:(MWKDataStore*)dataStore {
    self = [super init];
    if (self) {
        self.dataStore      = dataStore;
        self.entries        = [[NSMutableArray alloc] init];
        self.entriesByTitle = [[NSMutableDictionary alloc] init];
        NSDictionary* data = [self.dataStore historyListData];
        [self importData:data];
    }
    return self;
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state
                                  objects:(__unsafe_unretained id [])stackbuf
                                    count:(NSUInteger)len {
    return [self.entries countByEnumeratingWithState:state objects:stackbuf count:len];
}

#pragma mark - Data methods

- (void)importData:(NSDictionary*)data {
    NSArray* arr = data[@"entries"];
    if (arr) {
        for (NSDictionary* entryDict in arr) {
            MWKSavedPageEntry* entry = [[MWKSavedPageEntry alloc] initWithDict:entryDict];
            [self.entries addObject:entry];
            self.entriesByTitle[entry.title] = entry;
        }
    }
    self.dirty = NO;
}

- (id)dataExport {
    NSMutableArray* array = [[NSMutableArray alloc] init];

    for (MWKSavedPageEntry* entry in self.entries) {
        [array addObject:[entry dataExport]];
    }

    return @{@"entries": [NSArray arrayWithArray:array]};
}

#pragma mark - Entry Access

- (NSUInteger)length {
    return [self.entries count];
}

- (MWKSavedPageEntry*)entryAtIndex:(NSUInteger)index {
    return self.entries[index];
}

- (MWKSavedPageEntry*)entryForTitle:(MWKTitle*)title {
    MWKSavedPageEntry* entry = self.entriesByTitle[title];
    return entry;
}

- (BOOL)isSaved:(MWKTitle*)title {
    MWKSavedPageEntry* entry = [self entryForTitle:title];
    return (entry != nil);
}

- (NSUInteger)indexForEntry:(MWKHistoryEntry*)entry {
    return [self.entries indexOfObject:entry];
}

#pragma mark - Update Methods

- (BFTask*)savePageWithTitle:(MWKTitle*)title {
    if (title == nil) {
        return [BFTask taskWithError:nil];
    }

    MWKSavedPageEntry* entry = [[MWKSavedPageEntry alloc] initWithTitle:title];
    return [self addEntry:entry];
}

- (BFTask*)addEntry:(MWKSavedPageEntry*)entry {
    if (entry.title == nil) {
        return [BFTask taskWithError:nil];
    }
    MWKSavedPageEntry* oldEntry = [self entryForTitle:entry.title];
    if (oldEntry) {
        [self.entries removeObject:oldEntry];
    }

    entry.date = entry.date ? entry.date : [NSDate date];
    [self.entries insertObject:entry atIndex:0];
    self.entriesByTitle[entry.title] = entry;
    self.dirty                       = YES;

    return [BFTask taskWithResult:entry];
}

- (BFTask*)removeSavedPageWithTitle:(MWKTitle*)title {
    if (title == nil) {
        return [BFTask taskWithError:nil];
    }

    MWKSavedPageEntry* entry = [self entryForTitle:title];

    if (entry) {
        [self.entries removeObject:entry];
        [self.entriesByTitle removeObjectForKey:entry.title];
        self.dirty = YES;
    }

    return [BFTask taskWithResult:nil];
}

- (BFTask*)removeAllSavedPages {
    [self.entries removeAllObjects];
    [self.entriesByTitle removeAllObjects];
    self.dirty = YES;

    return [BFTask taskWithResult:nil];
}

#pragma mark - Save

- (BFTask*)save {
    NSError* error;
    if (self.dirty && ![self.dataStore saveSavedPageList:self error:&error]) {
        NSAssert(NO, @"Error saving saved pages: %@", [error localizedDescription]);
        return [BFTask taskWithError:error];
    } else {
        self.dirty = NO;
    }

    return [BFTask taskWithResult:nil];
}

@end
