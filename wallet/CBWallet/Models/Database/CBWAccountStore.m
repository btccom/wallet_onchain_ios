//
//  AccountStore.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWAccountStore.h"
#import "CBWDatabaseManager.h"

NSString *const AccountStoreWatchedAccountLabel = @"Label watched_account";

@implementation CBWAccountStore

- (void)fetch {
    [super fetch];
    [[CBWDatabaseManager defaultManager] fetchAccountsToStore:self];
}

- (CBWAccount *)customDefaultAccount {
    __block CBWAccount *account = (CBWAccount *)[records firstObject];
    [records enumerateObjectsUsingBlock:^(CBWRecordObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (((CBWAccount *)obj).isCustomDefaultEnabled) {
            account = (CBWAccount *)obj;
            *stop = YES;
        }
    }];
    return account;
}

- (CBWAccount *)watchedAccount {
    __block CBWAccount *account = [[CBWAccount alloc] init];
    account.idx = CBWRecordWatchedIdx;
    account.label = AccountStoreWatchedAccountLabel;
    [records enumerateObjectsUsingBlock:^(CBWRecordObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (((CBWAccount *)obj).idx == CBWRecordWatchedIdx) {
            account = (CBWAccount *)obj;
            *stop = YES;
        }
    }];
    return account;
}

@end
