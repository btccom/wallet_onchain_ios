//
//  AccountStore.m
//  CBWallet
//
//  Created by Zin on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AccountStore.h"
#import "DatabaseManager.h"

NSString *const AccountStoreWatchedAccountLabel = @"Watched Only Account";

@implementation AccountStore

- (void)fetch {
    [records removeAllObjects];
    [[DatabaseManager defaultManager] fetchAccountsToStore:self];
}

- (Account *)customDefaultAccount {
    __block Account *account = (Account *)[records firstObject];
    [records enumerateObjectsUsingBlock:^(RecordObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (((Account *)obj).isCustomDefaultEnabled) {
            account = (Account *)obj;
            *stop = YES;
        }
    }];
    return account;
}

- (Account *)watchedAccount {
    Account *account = [[Account alloc] init];
    account.idx = RecordWatchedIdx;
    account.label = AccountStoreWatchedAccountLabel;
    return account;
}

@end
