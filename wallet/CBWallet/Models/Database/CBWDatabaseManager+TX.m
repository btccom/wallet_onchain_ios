//
//  CBWDatabaseManager+TX.m
//  CBWallet
//
//  Created by Zin on 16/6/16.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWDatabaseManager+TX.h"

#import "CBWTransaction.h"

NSString *const DatabaseManagerTableTX = @"txmap";

NSString *const DatabaseManagerTXColCreatedAt = @"created_at";
NSString *const DatabaseManagerTXColHash = @"hash";
NSString *const DatabaseManagerTXColValue = @"balance_diff";
NSString *const DatabaseManagerTXColBlockHeight = @"block_height";
NSString *const DatabaseManagerTXColBlockTime = @"block_time";
NSString *const DatabaseManagerTXColQueryAddress = @"queryAddress";
NSString *const DatabaseManagerTXColRelatedAddresses = @"relatedAddresses";

@implementation CBWDatabaseManager (TX)

- (CBWTransaction *)txWithHash:(NSString *)hash andQueryAddress:(NSString *)address {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ? AND %@ = ?", DatabaseManagerTableTX, DatabaseManagerTXColHash, DatabaseManagerTXColQueryAddress];
    FMDatabase *db = [self db];
    if ([db open]) {
        
        CBWTransaction *transaction = nil;
        FMResultSet *rs = [db executeQuery:sql, hash, address];
        if ([rs next]) {
            transaction = [[CBWTransaction alloc] initWithDictionary:[rs resultDictionary]];
        }
        
        [db close];
        
        return transaction;
    }
    return nil;
}

- (BOOL)txInsertTransaction:(CBWTransaction *)transaction {
    BOOL inserted = NO;
    
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@) VALUES (?, ?, ?, ?, ?, ?, ?)", DatabaseManagerTableTX,
                         DatabaseManagerTXColCreatedAt,
                         DatabaseManagerTXColHash,
                         DatabaseManagerTXColValue,
                         DatabaseManagerTXColBlockHeight,
                         DatabaseManagerTXColBlockTime,
                         DatabaseManagerTXColQueryAddress,
                         DatabaseManagerTXColRelatedAddresses];
        NSData *relatedAddressesData = [NSJSONSerialization dataWithJSONObject:transaction.relatedAddresses options:0 error:nil];
        NSString *relatedAddresses = [[NSString alloc] initWithData:relatedAddressesData encoding:NSUTF8StringEncoding];
        inserted = [db executeUpdate:sql,
                    transaction.creationDate,
                    transaction.hashID,
                    @(transaction.value),
                    @(transaction.blockHeight),
                    transaction.blockTime,
                    transaction.queryAddress,
                    relatedAddresses];
        
        if (inserted) {
            transaction.rid = [db lastInsertRowId];
        }
        
        [db close];
    }
    
    return inserted;
}

- (BOOL)txUpdateTransaction:(CBWTransaction *)transaction {
    BOOL updated = NO;
    
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ = ?, %@ = ? WHERE %@ = ? AND %@ = ?", DatabaseManagerTableTX,
                         DatabaseManagerTXColBlockHeight,
                         DatabaseManagerTXColBlockTime,
                         DatabaseManagerTXColHash,
                         DatabaseManagerTXColQueryAddress];
        updated = [db executeUpdate:sql,
                   @(transaction.blockHeight),
                   transaction.blockTime,
                   transaction.hashID,
                   transaction.queryAddress];
        
        [db close];
    }
    
    return updated;
}

- (void)txSave:(CBWTransaction *)transaction withCompletion:(void (^)(CBWDatabaseChangeType changeType))completion {
    CBWTransaction *dbTransaction = [self txWithHash:transaction.hashID andQueryAddress:transaction.queryAddress];
    if (!dbTransaction) {
        if ([self txInsertTransaction:transaction]) {
            completion(CBWDatabaseChangeTypeInsert);
            return;
        }
    } else {
        if (dbTransaction.blockHeight == transaction.blockHeight) {
            completion(CBWDatabaseChangeTypeNone);
            return;
        }
        if ([self txUpdateTransaction:transaction]) {
            completion(CBWDatabaseChangeTypeUpdate);
            return;
        }
    }
    completion(CBWDatabaseChangeTypeFail);
}

- (void)txFetchWithQueryAddress:(NSString *)address completion:(void (^)(NSArray *))completion {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ? ORDER BY %@, %@", DatabaseManagerTableTX,
                     DatabaseManagerTXColQueryAddress,
                     DatabaseManagerTXColBlockTime,
                     DatabaseManagerTXColCreatedAt];
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSMutableArray *list = [NSMutableArray array];
        FMResultSet *rs = [db executeQuery:sql,
                           address];
        while ([rs next]) {
            [list addObject:[rs resultDictionary]];
        }
        completion([list copy]);
        
        [db close];
    } else {
        completion(nil);
    }
}

- (void)txFetchWithQueryAddress:(NSString *)address page:(NSUInteger)page pagesize:(NSUInteger)pagesize completion:(void (^)(NSArray *))completion {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ? ORDER BY %@ DESC LIMIT %lu OFFSET %lu", DatabaseManagerTableTX,
                     DatabaseManagerTXColQueryAddress,
                     DatabaseManagerTXColCreatedAt,
                     (unsigned long)pagesize,
                     (unsigned long)pagesize * (page - 1)];
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSMutableArray *list = [NSMutableArray array];
        FMResultSet *rs = [db executeQuery:sql, address];
        while ([rs next]) {
            [list addObject:[rs resultDictionary]];
        }
        completion([list copy]);
        
        [db close];
        return;
    }
    
    completion(nil);
}

- (NSUInteger)txCountWithQueryAddress:(NSString *)address {
    NSUInteger count = 0;
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@ = ?", DatabaseManagerTableTX, DatabaseManagerTXColQueryAddress];
    FMDatabase *db = [self db];
    if ([db open]) {
        
        FMResultSet *rs = [db executeQuery:sql, address];
        if ([rs next]) {
            count = [rs intForColumnIndex:0];
        }
        
        [db close];
    }
    return count;
}

@end
