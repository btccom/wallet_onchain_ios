//
//  Account.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWAccount.h"
#import "CBWAccountStore.h"

@implementation CBWAccount

- (void)setIdx:(NSInteger)idx {
    if (_idx != idx) {
        _idx = idx;
    }
}

+ (instancetype)newAccountWithIdx:(NSInteger)idx label:(NSString *)label inStore:(CBWAccountStore *)store {
    CBWAccount *account = [self newRecordInStore:store];
    account.idx = idx;
    account.label = label;
    return account;
}

+ (BOOL)checkLabel:(NSString *)label {
    return [[CBWDatabaseManager defaultManager] checkAccountLabel:label];
}

- (void)deleteFromStore {
    DLog(@"will never delete an account");
    return;
}

- (BOOL)saveWithError:(NSError *__autoreleasing  _Nullable *)error {
    BOOL initial = self.rid < 0;
    if (initial) {
        [self.store willChangeValueForKey:CBWRecordObjectStoreCountKey];
    }
    [[CBWDatabaseManager defaultManager] saveAccount:self];
    if (initial) {
        [self.store didChangeValueForKey:CBWRecordObjectStoreCountKey];
    }
    return NO;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"account %@: idx = %ld", self.label, (long)self.idx];
}

@end
