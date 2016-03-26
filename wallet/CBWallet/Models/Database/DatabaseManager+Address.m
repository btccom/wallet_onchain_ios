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


- (void)fetchAddressToStore:(AddressStore *)store {
    FMDatabase *db = [self db];
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", DatabaseManagerTableAccount];
        FMResultSet *results = [db executeQuery:sql];
        while ([results next]) {
            Address *address = [[Address alloc] init];
            address.rid = [results intForColumn:DatabaseManagerColRid];
            address.idx = [results intForColumn:DatabaseManagerColRid];
            address.address = [results stringForColumn:DatabaseManagerColAddress];
            address.label = [results stringForColumn:DatabaseManagerColLabel];
            address.dirty = [results boolForColumn:DatabaseManagerColDirty];
            address.balance = [results longLongIntForColumn:DatabaseManagerColBalance];
            address.txCount = [results intForColumn:DatabaseManagerColTxCount];
            address.accountIdx = [results intForColumn:DatabaseManagerColAccountIdx];
            address.accountRid = [results intForColumn:DatabaseManagerColAccountRid];
            [store addRecord:address];
        }
        [db close];
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
    DLog(@"create account: %@", address);
    
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", DatabaseManagerTableAddress,
                         DatabaseManagerColCreationDate,
                         DatabaseManagerColModificationDate,
                         DatabaseManagerColIdx,
                         DatabaseManagerColAddress,
                         DatabaseManagerColLabel,
                         DatabaseManagerColDirty,
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
                   @(address.dirty),
                   @(address.balance),
                   @(address.txCount),
                   @(address.accountRid),
                   @(address.accountIdx)];
        if (created) {
            address.rid = [db lastInsertRowId];
        }
        
        [db close];
    }
    
    return created;
}
- (NSInteger)p_addressExistsWithAddress:(NSString *)aAddress {
    NSInteger rid = -1;
    
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?", DatabaseManagerTableAccount,
                         DatabaseManagerColIdx];
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
    DLog(@"update account: %@", address);
    
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ? WHERE %@ = ?", DatabaseManagerTableAddress,
                         DatabaseManagerColCreationDate,
                         DatabaseManagerColModificationDate,
                         DatabaseManagerColIdx,
                         DatabaseManagerColAddress,
                         DatabaseManagerColLabel,
                         DatabaseManagerColDirty,
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
                   @(address.dirty),
                   @(address.balance),
                   @(address.txCount),
                   @(address.accountRid),
                   @(address.accountIdx),
                   @(address.rid)];
        
        [db close];
    }
    
    return updated;
}

@end
