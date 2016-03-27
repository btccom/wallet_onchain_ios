//
//  DatabaseManager+Address.m
//  CBWallet
//
//  Created by Zin on 16/3/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "DatabaseManager+Address.h"
#import "AddressStore.h"

@implementation DatabaseManager (Address)


- (void)fetchAddressWithAccountIdx:(NSInteger)accountIdx toStore:(AddressStore *)store {
    [self fetchAddressWithAccountIdx:accountIdx archived:NO toStore:store];
}

- (void)fetchAddressWithAccountIdx:(NSInteger)accountIdx archived:(BOOL)archived toStore:(AddressStore *)store {
    FMDatabase *db = [self db];
    if ([db open]) {
        NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?", DatabaseManagerTableAddress,
                                DatabaseManagerColArchived];
        FMResultSet *results = nil;
        if (accountIdx > -2) {// -1 for watched only
            [sql appendFormat:@" AND %@ = ?", DatabaseManagerColAccountIdx];
            DLog(@"database manager fetch addresses of account: %ld", accountIdx);
            results = [db executeQuery:sql,
                       @(archived),
                       @(accountIdx)];
        } else {
            results = [db executeQuery:sql,
                       @(archived)];
        }
        NSLog(@"database manager fetched address results: %@", results);
        [self p_transformResultSet:results toStore:store];
        [db close];
    }
}

- (void)p_transformResultSet:(FMResultSet *)results toStore:(AddressStore *)store {
    while ([results next]) {
        Address *address = [[Address alloc] init];
        address.rid = [results intForColumn:DatabaseManagerColRid];
        address.idx = [results intForColumn:DatabaseManagerColRid];
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

- (void)saveAddress:(Address *)address {
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
}
- (BOOL)p_createAddress:(Address *)address {
    BOOL created = NO;
    DLog(@"create address: %@", address);
    
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
    
    DLog(@"database manager create address: %@, %d", address.address, created);
    
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
- (BOOL)p_updateAddress:(Address *)address {
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

- (NSUInteger)countAllAddressesWithAccountIdx:(NSInteger)accountIdx {
    NSUInteger count = 0;
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@", DatabaseManagerTableAddress];
        FMResultSet *results = [db executeQuery:sql];
        if ([results next]) {
            count = [results intForColumnIndex:0];
        }
        
        [db close];
    }
    return count;
}

@end
