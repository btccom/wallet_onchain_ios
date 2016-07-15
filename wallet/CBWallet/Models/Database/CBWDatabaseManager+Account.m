//
//  DatabaseManager+Account.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/21.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWDatabaseManager+Account.h"
#import "CBWAccountStore.h"

#import "CBWBackup.h"

@implementation CBWDatabaseManager (Account)

- (void)fetchAccountsToStore:(CBWAccountStore *)store {
    FMDatabase *db = [self db];
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@", DatabaseManagerTableAccount, DatabaseManagerColIDX];
        FMResultSet *results = [db executeQuery:sql];
        while ([results next]) {
            CBWAccount *account = [[CBWAccount alloc] init];
            account.rid = [results intForColumn:DatabaseManagerColRID];
            account.creationDate = [results dateForColumn:DatabaseManagerColCreationDate];
            account.modificationDate = [results dateForColumn:DatabaseManagerColModificationDate];
            account.idx = [results intForColumn:DatabaseManagerColIDX];
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
    if (!account.isIgnoringSync) {
        [CBWBackup saveToCloudKitWithCompletion:^(NSError *error) {
            DLog(@"account database push to icloud error: %@", error);
        }];
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
                         DatabaseManagerColIDX,
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
                         DatabaseManagerColIDX];
        FMResultSet *result = [db executeQuery:sql, @(idx)];
        if ([result next]) {
            rid = [result intForColumn:DatabaseManagerColRID];
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
                         DatabaseManagerColIDX,
                         DatabaseManagerColLabel,
                         DatabaseManagerColCustomDefaultEnabled,
                         DatabaseManagerColRID];
        updated = [db executeUpdate:sql,
                   account.creationDate,
                   account.modificationDate,
                   @(account.idx),
                   account.label,
                   @(account.isCustomDefaultEnabled),
                   @(account.rid)];
        
        [db close];
    }
    
    return updated;
}

- (BOOL)checkAccountLabel:(NSString *)label {
    BOOL checked = NO;
    FMDatabase *db = [self db];
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?", DatabaseManagerTableAccount,
                         DatabaseManagerColLabel];
        FMResultSet *result = [db executeQuery:sql,
                               label];
        checked = [result next];
        [db close];
    }
    return checked;
}

+ (BOOL)checkAccountInstalled {
    BOOL installed = NO;
    FMDatabase *db = [self installDb];
    if ([db open]) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?", DatabaseManagerTableAccount,
                         DatabaseManagerColIDX];
        FMResultSet *results = [db executeQuery:sql,
                                @(0)];
        if ([results next]) {
            installed = YES;
        }
        [db close];
    }
    return installed;
}

- (NSDictionary *)analyzeAllAccountAddresses {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ > ?", DatabaseManagerTableAddress,
                         DatabaseManagerColAccountIDX];
        FMResultSet *resultSet = [db executeQuery:sql,
                                  @(CBWRecordWatchedIDX)];
        long long balance = 0;
        long long received = 0;
        long long sent = 0;
        NSInteger txCount = 0;
        while ([resultSet next]) {
            balance += [resultSet longForColumn:DatabaseManagerColBalance];
            received += [resultSet longForColumn:DatabaseManagerColReceived];
            sent += [resultSet longForColumn:DatabaseManagerColSent];
            txCount += [resultSet intForColumn:DatabaseManagerColTXCount];
        }
        
        [dictionary setObject:@(balance) forKey:CBWAccountTotalBalanceKey];
        [dictionary setObject:@(received) forKey:CBWAccountTotalReceivedKey];
        [dictionary setObject:@(sent) forKey:CBWAccountTotalSentKey];
        [dictionary setObject:@(txCount) forKey:CBWAccountTotalTXCountKey];
        
        [db close];
    }
    return [dictionary copy];
}

- (NSDictionary *)analyzeAccountWithIDX:(NSInteger)idx {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?", DatabaseManagerTableAddress,
                         DatabaseManagerColAccountIDX];
        FMResultSet *resultSet = [db executeQuery:sql,
                                  @(idx)];
        long long balance = 0;
        NSInteger txCount = 0;
        while ([resultSet next]) {
            balance += [resultSet longLongIntForColumn:DatabaseManagerColBalance];
            txCount += [resultSet intForColumn:DatabaseManagerColTXCount];
        }
        
        [dictionary setObject:@(balance) forKey:CBWAccountTotalBalanceKey];
        [dictionary setObject:@(txCount) forKey:CBWAccountTotalTXCountKey];
        
        [db close];
    }
    return [dictionary copy];
}

@end
