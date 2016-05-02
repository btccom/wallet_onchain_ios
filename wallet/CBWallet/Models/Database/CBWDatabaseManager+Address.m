//
//  DatabaseManager+Address.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWDatabaseManager+Address.h"
#import "CBWAddressStore.h"
#import "CBWBackup.h"

@implementation CBWDatabaseManager (Address)


- (void)fetchAddressWithAccountIdx:(NSInteger)accountIdx toStore:(CBWAddressStore *)store {
    [self fetchAddressWithAccountIdx:accountIdx archived:NO toStore:store];
}

- (void)fetchAddressWithAccountIdx:(NSInteger)accountIdx archived:(BOOL)archived toStore:(CBWAddressStore *)store {
    FMDatabase *db = [self db];
    if ([db open]) {
        NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?", DatabaseManagerTableAddress,
                                DatabaseManagerColArchived];
        FMResultSet *results = nil;
        if (accountIdx > -2) {// -1 for watched only
            [sql appendFormat:@" AND %@ = ?", DatabaseManagerColAccountIdx];
            DLog(@"database manager fetch addresses of account: %ld", (long)accountIdx);
            results = [db executeQuery:sql,
                       @(archived),
                       @(accountIdx)];
        } else {
            results = [db executeQuery:sql,
                       @(archived)];
        }
        [self p_transformResultSet:results toStore:store];
        [db close];
    }
}

- (void)p_transformResultSet:(FMResultSet *)results toStore:(CBWAddressStore *)store {
    while ([results next]) {
        CBWAddress *address = [[CBWAddress alloc] init];
        address.rid = [results intForColumn:DatabaseManagerColRid];
        address.idx = [results intForColumn:DatabaseManagerColIdx];
        address.address = [results stringForColumn:DatabaseManagerColAddress];
        address.label = [results stringForColumn:DatabaseManagerColLabel];
        address.archived = [results boolForColumn:DatabaseManagerColArchived];
        address.dirty = [results boolForColumn:DatabaseManagerColDirty];
        address.internal = [results boolForColumn:DatabaseManagerColInternal];
        address.balance = [results longLongIntForColumn:DatabaseManagerColBalance];
        address.txCount = [results intForColumn:DatabaseManagerColTxCount];
        address.accountIdx = [results intForColumn:DatabaseManagerColAccountIdx];
        address.accountRid = [results intForColumn:DatabaseManagerColAccountRid];
        [store addRecord:address];
    }
}

- (void)saveAddress:(CBWAddress *)address {
    if (address.rid < 0) {
        // 新记录
        [self p_createAddress:address];
    } else {
        // 更新
        NSInteger rid = [self p_addressExistsWithAddress:address.address];
        if (rid > 0) {
            [self p_updateAddress:address];
        } else {
            [self p_createAddress:address];
        }
    }
    
    if (!address.isIgnoringSync) {
        [CBWBackup saveToCloudKitWithCompletion:^(NSError *error) {
            DLog(@"address database push to icloud error: %@", error);
        }];
    }
}
- (BOOL)p_createAddress:(CBWAddress *)address {
    BOOL created = NO;
    DLog(@"database manager create address: %@, idx: %ld", address, (long)address.idx);
    
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", DatabaseManagerTableAddress,
                         DatabaseManagerColCreationDate,
                         DatabaseManagerColModificationDate,
                         DatabaseManagerColIdx,
                         DatabaseManagerColAddress,
                         DatabaseManagerColLabel,
                         DatabaseManagerColArchived,
                         DatabaseManagerColDirty,
                         DatabaseManagerColInternal,
                         DatabaseManagerColBalance,
                         DatabaseManagerColTxCount,
                         DatabaseManagerColAccountRid,
                         DatabaseManagerColAccountIdx];
        
        created = [db executeUpdate:sql,
                   address.creationDate,
                   address.modificationDate,
                   @(address.idx),
                   address.address,
                   address.label,
                   @(address.isArchived),
                   @(address.dirty),
                   @(address.internal),
                   @(address.balance),
                   @(address.txCount),
                   @(address.accountRid),
                   @(address.accountIdx)];
        if (created) {
            address.rid = [db lastInsertRowId];
        }
        
        [db close];
    }
    
    DLog(@"database manager created address: %@, success? %d", address.address, created);
    
    return created;
}
- (NSInteger)p_addressExistsWithAddress:(NSString *)aAddress {
    NSInteger rid = -1;
    
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?", DatabaseManagerTableAddress,
                         DatabaseManagerColAddress];
        FMResultSet *result = [db executeQuery:sql, aAddress];
        if ([result next]) {
            rid = [result intForColumn:DatabaseManagerColRid];
        }
        
        [db close];
    }
    
    return rid;
}
- (BOOL)p_updateAddress:(CBWAddress *)address {
    BOOL updated = NO;
    DLog(@"update address: %@", address);
    
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ? WHERE %@ = ?", DatabaseManagerTableAddress,
                         DatabaseManagerColCreationDate,
                         DatabaseManagerColModificationDate,
                         DatabaseManagerColIdx,
                         DatabaseManagerColAddress,
                         DatabaseManagerColLabel,
                         DatabaseManagerColArchived,
                         DatabaseManagerColDirty,
                         DatabaseManagerColInternal,
                         DatabaseManagerColBalance,
                         DatabaseManagerColTxCount,
                         DatabaseManagerColAccountRid,
                         DatabaseManagerColAccountIdx,
                         DatabaseManagerColRid];
        updated = [db executeUpdate:sql,
                   address.creationDate,
                   address.modificationDate,
                   @(address.idx),
                   address.address,
                   address.label,
                   @(address.isArchived),
                   @(address.dirty),
                   @(address.internal),
                   @(address.balance),
                   @(address.txCount),
                   @(address.accountRid),
                   @(address.accountIdx),
                   @(address.rid)];
        
        [db close];
    }
    
    DLog(@"database manager update address: %@, %d", address.address, updated);
    
    return updated;
}

- (void)deleteAddress:(CBWAddress *)address {
    DLog(@"delete address from database: %@", address);
    if (address.accountIdx != CBWRecordWatchedIdx) {
        return;
    }
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ? AND %@ = ?", DatabaseManagerTableAddress,
                         DatabaseManagerColRid,
                         DatabaseManagerColAddress];
        if (![db executeUpdate:sql,
              @(address.rid),
              address.address]) {
            NSLog(@"can not delete address from database.");
        }
        
        [db close];
    }
    
    
    if (!address.isIgnoringSync) {
        [CBWBackup saveToCloudKitWithCompletion:^(NSError *error) {
            DLog(@"address database push 'delete' to icloud error: %@", error);
        }];
    }
}

- (NSUInteger)countAllAddressesWithAccountIdx:(NSInteger)accountIdx {
    NSUInteger count = 0;
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@ = ?", DatabaseManagerTableAddress,
                         DatabaseManagerColAccountIdx];
        FMResultSet *results = [db executeQuery:sql,
                                @(accountIdx)];
        if ([results next]) {
            count = [results intForColumnIndex:0];
        }
        
        [db close];
    }
    return count;
}

@end
