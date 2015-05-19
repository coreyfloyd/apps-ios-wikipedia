//
//  MWKUserDataStore.m
//  MediaWikiKit
//
//  Created by Brion on 11/18/14.
//  Copyright (c) 2014 Wikimedia Foundation. All rights reserved.
//

#import "MediaWikiKit.h"

@interface MWKUserDataStore ()

@property (readwrite, weak, nonatomic) MWKDataStore* dataStore;
@property (readwrite, strong, nonatomic) MWKHistoryList* historyList;
@property (readwrite, strong, nonatomic) MWKSavedPageList* savedPageList;
@property (readwrite, strong, nonatomic) MWKRecentSearchList* recentSearchList;

@end

@implementation MWKUserDataStore

- (instancetype)initWithDataStore:(MWKDataStore*)dataStore {
    self = [self init];
    if (self) {
        self.dataStore = dataStore;
    }
    return self;
}

- (MWKHistoryList*)historyList {
    if (_historyList == nil) {
        _historyList = [[MWKHistoryList alloc] initWithDataStore:self.dataStore];
    }
    return _historyList;
}

- (MWKSavedPageList*)savedPageList {
    if (_savedPageList == nil) {
        _savedPageList = [[MWKSavedPageList alloc] initWithDataStore:self.dataStore];
    }
    return _savedPageList;
}

- (MWKRecentSearchList*)recentSearchList {
    if (_recentSearchList) {
        _recentSearchList = [[MWKRecentSearchList alloc] initWithDataStore:self.dataStore];
    }
    return _recentSearchList;
}

- (BFTask*)saveWithCompletedTask:(BFTask*)task {
    return [[[task continueWithSuccessBlock:^id (BFTask* task) {
        return [self.historyList save];
    }] continueWithSuccessBlock:^id (BFTask* task) {
        return [self.savedPageList save];
    }] continueWithSuccessBlock:^id (BFTask* task) {
        return [self.recentSearchList save];
    }];
}

- (BFTask*)save {
    return [self saveWithCompletedTask:[BFTask taskWithResult:nil]];
}

- (BFTask*)reset {
    self.historyList      = nil;
    self.savedPageList    = nil;
    self.recentSearchList = nil;

    return [BFTask taskWithResult:nil];
}

@end
