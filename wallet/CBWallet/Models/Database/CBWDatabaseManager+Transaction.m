//
//  CBWDatabaseManager+Transaction.m
//  CBWallet
//
//  Created by Zin on 16/6/23.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWDatabaseManager+Transaction.h"

#import "CBWTransaction.h"

NSString *const DatabaseManagerTableTransaction = @"transaction";

NSString *const DatabaseManagerTransactionColHash = @"hash";
NSString *const DatabaseManagerTransactionColIsCoinbase = @"is_coinbase";
NSString *const DatabaseManagerTransactionColFee = @"fee";
NSString *const DatabaseManagerTransactionColBlockHeight = @"block_height";
NSString *const DatabaseManagerTransactionColBlockTime = @"block_time";
NSString *const DatabaseManagerTransactionColSize = @"size";
NSString *const DatabaseManagerTransactionColVersion = @"version";
NSString *const DatabaseManagerTransactionColInputsValue = @"inputs_value";
NSString *const DatabaseManagerTransactionColInputsCount = @"inputs_count";
NSString *const DatabaseManagerTransactionColInputs = @"inputs";
NSString *const DatabaseManagerTransactionColOutputsValue = @"outputs_value";
NSString *const DatabaseManagerTransactionColOutputsCount = @"outputs_count";
NSString *const DatabaseManagerTransactionColOutputs = @"outputs";
NSString *const DatabaseManagerTransactionColAccountIDX = @"accountIdx";

@implementation CBWDatabaseManager (Transaction)

- (CBWTransaction *)transactionWithHash:(NSString *)hash {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?", DatabaseManagerTableTransaction, DatabaseManagerTransactionColHash];
    FMDatabase *db = [self db];
    if ([db open]) {
        
        CBWTransaction *transaction = nil;
        FMResultSet *rs = [self.db executeQuery:sql, hash];
        if ([rs next]) {
            transaction = [[CBWTransaction alloc] initWithDictionary:[rs resultDictionary]];
        }
        
        [db close];
        
        return transaction;
    }
    return nil;
}

- (BOOL)transactionInsertTransaction:(CBWTransaction *)transaction {
    BOOL inserted = NO;
    
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", DatabaseManagerTableTransaction,
                         DatabaseManagerColCreationDate,
                         DatabaseManagerTransactionColHash,
                         DatabaseManagerTransactionColIsCoinbase,
                         DatabaseManagerTransactionColFee,
                         DatabaseManagerTransactionColBlockHeight,
                         DatabaseManagerTransactionColBlockTime,
                         DatabaseManagerTransactionColSize,
                         DatabaseManagerTransactionColVersion,
                         DatabaseManagerTransactionColInputsValue,
                         DatabaseManagerTransactionColInputsCount,
                         DatabaseManagerTransactionColInputs,
                         DatabaseManagerTransactionColOutputsValue,
                         DatabaseManagerTransactionColOutputsCount,
                         DatabaseManagerTransactionColOutputs,
                         DatabaseManagerTransactionColAccountIDX];
        NSData *inputsData = [NSJSONSerialization dataWithJSONObject:transaction.inputs options:0 error:nil];
        NSString *inputs = [[NSString alloc] initWithData:inputsData encoding:NSUTF8StringEncoding];
        NSData *outputsData = [NSJSONSerialization dataWithJSONObject:transaction.outputs options:0 error:nil];
        NSString *outputs = [[NSString alloc] initWithData:outputsData encoding:NSUTF8StringEncoding];
        inserted = [db executeUpdate:sql,
                    transaction.creationDate,
                    transaction.hashID,
                    @(transaction.isCoinbase),
                    @(transaction.fee),
                    @(transaction.blockHeight),
                    transaction.blockTime,
                    @(transaction.size),
                    @(transaction.version),
                    @(transaction.inputsValue),
                    @(transaction.inputsCount),
                    inputs,
                    @(transaction.outputsValue),
                    @(transaction.outputsCount),
                    outputs,
                    @(transaction.accountIDX)];
        
        if (inserted) {
            transaction.rid = [db lastInsertRowId];
        }
        
        [db close];
    }
    
    return inserted;
}

- (BOOL)transactionUpdateTransaction:(CBWTransaction *)transaction {
    BOOL updated = NO;
    
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ = ?, %@ = ?, %@ = ?, %@ = ? WHERE %@ = ?", DatabaseManagerTableTransaction,
                         DatabaseManagerTransactionColBlockHeight,
                         DatabaseManagerTransactionColBlockTime,
                         DatabaseManagerTransactionColSize,
                         DatabaseManagerTransactionColVersion,
                         DatabaseManagerTransactionColHash];
        updated = [db executeUpdate:sql,
                   @(transaction.blockHeight),
                   transaction.blockTime,
                   @(transaction.size),
                   @(transaction.version),
                   transaction.hashID];
        
        [db close];
    }
    
    return updated;
}

- (void)transactionSave:(CBWTransaction *)transaction withCompletion:(void (^)(CBWDatabaseChangeType))completion {
    CBWTransaction *dbTransaction = [self transactionWithHash:transaction.hashID];
    if (!dbTransaction) {
        if ([self transactionInsertTransaction:transaction]) {
            completion(CBWDatabaseChangeTypeInsert);
            return;
        }
    } else {
        if (dbTransaction.blockHeight == transaction.blockHeight) {
            completion(CBWDatabaseChangeTypeNone);
            return;
        }
        if ([self transactionUpdateTransaction:transaction]) {
            completion(CBWDatabaseChangeTypeUpdate);
            return;
        }
    }
    completion(CBWDatabaseChangeTypeFail);
}

- (void)transactionFetchWithAccountIDX:(NSInteger)idx completion:(void (^)(NSArray *))completion {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ? ORDER BY %@ DESC", DatabaseManagerTableTransaction, DatabaseManagerTransactionColAccountIDX, DatabaseManagerColCreationDate];
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSMutableArray *list = [NSMutableArray array];
        FMResultSet *rs = [self.db executeQuery:sql, @(idx)];
        while ([rs next]) {
            [list addObject:[rs resultDictionary]];
        }
        completion([list copy]);
        
        [db close];
        return;
    }
    
    completion(nil);
}

- (void)transactionFetchWithAccountIDX:(NSInteger)idx page:(NSUInteger)page pagesize:(NSUInteger)pagesize completion:(void (^)(NSArray *))completion {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ? LIMIT %lu OFFSET %lu ORDER BY %@ DESC", DatabaseManagerTableTransaction,
                     DatabaseManagerTransactionColAccountIDX,
                     (unsigned long)pagesize,
                     (unsigned long)pagesize * (page - 1),
                     DatabaseManagerColCreationDate];
    FMDatabase *db = [self db];
    if ([db open]) {
        
        NSMutableArray *list = [NSMutableArray array];
        FMResultSet *rs = [self.db executeQuery:sql, @(idx)];
        while ([rs next]) {
            [list addObject:[rs resultDictionary]];
        }
        completion([list copy]);
        
        [db close];
        return;
    }
    
    completion(nil);
}

- (NSUInteger)transactionCountWithAccountIDX:(NSInteger)idx {
    NSUInteger count = 0;
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@ = ?", DatabaseManagerTableTransaction, DatabaseManagerTransactionColAccountIDX];
    FMDatabase *db = [self db];
    if ([db open]) {
        
        FMResultSet *rs = [db executeQuery:sql, @(idx)];
        if ([rs next]) {
            count = [rs intForColumnIndex:0];
        }
        
        [db close];
    }
    return count;
}

@end
