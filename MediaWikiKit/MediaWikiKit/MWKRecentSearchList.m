//
//  MWKRecentSearchList.m
//  MediaWikiKit
//
//  Created by Brion on 11/18/14.
//  Copyright (c) 2014 Wikimedia Foundation. All rights reserved.
//

#import "MediaWikiKit.h"

@interface MWKRecentSearchList ()

@property (readwrite, nonatomic, assign) BOOL dirty;
@property (nonatomic, strong) NSMutableArray* entries;

@end

@implementation MWKRecentSearchList

- (instancetype)init {
    self = [super init];
    if (self) {
        self.entries = [[NSMutableArray alloc] init];
    }
    self.dirty = NO;
    return self;
}

- (instancetype)initWithDict:(NSDictionary*)dict {
    self = [self init];
    if (self) {
        for (NSDictionary* entryDict in dict[@"entries"]) {
            MWKRecentSearchEntry* entry = [[MWKRecentSearchEntry alloc] initWithDict:entryDict];
            [self.entries addObject:entry];
        }
    }
    self.dirty = NO;
    return self;
}

- (NSUInteger)length {
    return [self.entries count];
}

- (id)dataExport {
    NSMutableArray* dicts = [[NSMutableArray alloc] init];
    for (MWKRecentSearchEntry* entry in self.entries) {
        [dicts addObject:[entry dataExport]];
    }
    self.dirty = NO;
    return @{@"entries": dicts};
}

- (void)addEntry:(MWKRecentSearchEntry*)entry {
    if ([entry.searchTerm length] == 0) {
        return;
    }

    NSUInteger oldIndex = [self.entries indexOfObjectPassingTest:^BOOL (MWKRecentSearchEntry* obj, NSUInteger idx, BOOL* stop) {
        if ([entry.searchTerm isEqualToString:obj.searchTerm]) {
            *stop = YES;
            return YES;
        }

        return NO;
    }];
    if (oldIndex != NSNotFound) {
        // Move to top!
        [self.entries removeObjectAtIndex:oldIndex];
    }
    [self.entries insertObject:entry atIndex:0];
    self.dirty = YES;
    // @todo trim to max?
}

- (void)removeEntry:(MWKRecentSearchEntry*)entry; {
    NSUInteger oldIndex = [self.entries indexOfObject:entry];

    if (oldIndex != NSNotFound) {
        [self.entries removeObjectAtIndex:oldIndex];
    }
    self.dirty = YES;
}


- (void)removeAllEntries {
    [self.entries removeAllObjects];
    self.dirty = YES;
}

- (MWKRecentSearchEntry*)entryAtIndex:(NSUInteger)index {
    return self.entries[index];
}

@end
