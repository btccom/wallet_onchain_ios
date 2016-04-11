//
//  DatabaseManager+Account.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/21.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWDatabaseManager+Account.h"
#import "CBWAccountStore.h"

@implementation CBWDatabaseManager (Account)

- (void)fetchAccountsToStore:(CBWAccountStore *)store {
    FMDatabase *db = [self db];
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@", DatabaseManagerTableAccount, DatabaseManagerColIdx];
        FMResultSet *results = [db executeQuery:sql];
        while ([results next]) {
            CBWAccount *account = [[CBWAccount alloc] init];
            account.rid = [results intForColumn:DatabaseManagerColRid];
            account.creationDate = [results dateForColumn:DatabaseManagerColCreationDate];
            account.modificationDate = [results dateForColumn:DatabaseManagerColModificationDate];
            account.idx = [results intForColumn:DatabaseManagerColIdx];
            account.label = [results stringForColumn:DatabaseManagerColLabel];
            [store addRecord:account];
        }
        [db close];
    }
}

- (void)saveAccount:(CBWAccount *)account {
    if (account.rid < 0) {
        // 新记录
        [self p_createAccount:account];
    } else {
        // 更新
        NSInteger rid = [self p_accountExistsWithIdx:account.idx];
        if (rid > 0) {
            [self p_updateAccount:account];
        } else {
            [self p_createAccount:account];
        }
    }
}
- (BOOL)p_createAccount:(CBWAccount *)account {
    BOOL created = NO;
    DLog(@"create account: %@", account);
    
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@, %@, %@, %@) VALUES (?, ?, ?, ?, ?)", DatabaseManagerTableAccount,
                         DatabaseManagerColCreationDate,
                         DatabaseManagerColModificationDate,
                         DatabaseManagerColIdx,
                         DatabaseManagerColLabel,
                         DatabaseManagerColCustomDefaultEnabled];
        
        created = [db executeUpdate:sql,
                   account.creationDate,
                   account.modificationDate,
                   @(account.idx),
                   account.label,
                   @(account.isCustomDefaultEnabled)];
        if (created) {
            account.rid = [db lastInsertRowId];
        }
        
        [db close];
    }
    
    return created;
}
- (NSInteger)p_accountExistsWithIdx:(NSUInteger)idx {
    NSInteger rid = -1;
    
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?", DatabaseManagerTableAccount,
                         DatabaseManagerColIdx];
        FMResultSet *result = [db executeQuery:sql, @(idx)];
        if ([result next]) {
            rid = [result intForColumn:DatabaseManagerColRid];
        }
        
        [db close];
    }
    
    return rid;
}
- (BOOL)p_updateAccount:(CBWAccount *)account {
    BOOL updated = NO;
    DLog(@"update account: %@", account);
    
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ? WHERE %@ = ?", DatabaseManagerTableAccount,
                         DatabaseManagerColCreationDate,
                         DatabaseManagerColModificationDate,
                         DatabaseManagerColIdx,
                         DatabaseManagerColLabel,
                         DatabaseManagerColRid,
                         DatabaseManagerColCustomDefaultEnabled];
        updated = [db executeUpdate:sql,
                   account.creationDate,
                   account.modificationDate,
                   @(account.idx),
                   account.label,
                   @(account.rid),
                   @(account.isCustomDefaultEnabled)];
        
        [db close];
    }
    
    return updated;
}

+ (BOOL)checkAccountInstalled {
    BOOL installed = NO;
    FMDatabase *db = [self installDb];
    if ([db open]) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?", DatabaseManagerTableAccount,
                         DatabaseManagerColIdx];
        FMResultSet *results = [db executeQuery:sql,
                                @(0)];
        if ([results next]) {
            installed = YES;
        }
        [db close];
    }
    return installed;
}

@end
