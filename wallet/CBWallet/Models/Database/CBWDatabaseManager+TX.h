//
//  CBWDatabaseManager+TX.h
//  CBWallet
//
//  Created by Zin on 16/6/23.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWDatabaseManager.h"

extern NSString *const DatabaseManagerTableTransaction;

/// date
extern NSString *const DatabaseManagerTransactionColCreatedAt;
/// string
extern NSString *const DatabaseManagerTransactionColHash;
/// bool (integer)
extern NSString *const DatabaseManagerTransactionColIsCoinbase;
/// integer, = inputs value - outpus value
extern NSString *const DatabaseManagerTransactionColFee;
/// integer -1 (unconfirmed) or > -1
extern NSString *const DatabaseManagerTransactionColBlockHeight;
/// date optional
extern NSString *const DatabaseManagerTransactionColBlockTime;
/// integer
extern NSString *const DatabaseManagerTransactionColSize;
/// integer
extern NSString *const DatabaseManagerTransactionColVersion;
/// integer
extern NSString *const DatabaseManagerTransactionColInputsValue;
/// integer
extern NSString *const DatabaseManagerTransactionColInputsCount;
/// string (array json)
extern NSString *const DatabaseManagerTransactionColInputs;
/// integer
extern NSString *const DatabaseManagerTransactionColOutputsValue;
/// integer
extern NSString *const DatabaseManagerTransactionColOutputsCount;
/// string (array json)
extern NSString *const DatabaseManagerTransactionColOutputs;
/// integer
extern NSString *const DatabaseManagerTransactionColAccountIDX;

@class CBWTransaction, CBWTransactionStore;

/// 
@interface CBWDatabaseManager (TX)

- (CBWTransaction *)transactionWithHash:(NSString *)hash;
/// call <code>trnasactionWithHash:</code> first to check
- (BOOL)transactionInsertTransaction:(CBWTransaction *)transaction;
/// just update block height, block time, size, version
- (BOOL)transactionUpdateTransaction:(CBWTransaction *)transaction;
/// check then insert or update
- (void)transactionSave:(CBWTransaction *)transaction withCompletion:(void (^)(CBWDatabaseChangeType changeType))completion;

- (NSUInteger)transactionCountWithAddresses:(NSArray *)addresses;

- (void)transactionFetchWithAddresses:(NSArray *)addresses page:(NSUInteger)page pagesize:(NSUInteger)pagesize completion:(void (^)(NSArray *response))completion;

@end
