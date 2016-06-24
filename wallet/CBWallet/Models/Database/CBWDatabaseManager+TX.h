//
//  CBWDatabaseManager+TX.h
//  CBWallet
//
//  Created by Zin on 16/6/16.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWDatabaseManager.h"

extern NSString *const DatabaseManagerTableTX;

/// string
extern NSString *const DatabaseManagerTXColHash;
/// integer, output value of query address - input value of query address
extern NSString *const DatabaseManagerTXColValue;
/// integer -1 (unconfirmed) or > -1
extern NSString *const DatabaseManagerTXColBlockHeight;
/// date optional
extern NSString *const DatabaseManagerTXColBlockTime;
/// string
extern NSString *const DatabaseManagerTXColQueryAddress;
/// string (array json)
extern NSString *const DatabaseManagerTXColRelatedAddresses;

@class CBWTransaction, CBWTransactionStore;

/// 交易哈希与地址映射，可以快速查找某个地址的本地交易缓存，如 first tx，last tx，first unconfirmed tx；
///
/// 或用于在地址页面显示交易摘要
@interface CBWDatabaseManager (TX)

- (CBWTransaction *)txWithHash:(NSString *)hash andQueryAddress:(NSString *)address;
- (BOOL)txInsertTransaction:(CBWTransaction *)transaction;
- (BOOL)txUpdateTransaction:(CBWTransaction *)transaction;
/// check tx, transaction
///
/// then save(insert or update) transaction, tx
- (void)txSave:(CBWTransaction *)transaction withCompletion:(void (^)(CBWDatabaseChangeType changeType))completion;

/// 一次拉取全部交易
- (void)txFetchWithQueryAddress:(NSString *)address completion:(void(^)(NSArray *response))completion;
/// 分页拉取交易
- (void)txFetchWithQueryAddress:(NSString *)address page:(NSUInteger)page pagesize:(NSUInteger)pagesize completion:(void (^)(NSArray *))completion;
/// 查询本地全部交易数量
- (NSUInteger)txCountWithQueryAddress:(NSString *)address;
@end
