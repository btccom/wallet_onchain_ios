//
//  CBWDatabaseManager+Transaction.h
//  CBWallet
//
//  Created by Zin on 16/6/23.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWDatabaseManager.h"

extern NSString *const DatabaseManagerTableTransaction;

/// string
extern NSString *const DatabaseManagerTransactionColHash;
/// bool (integer)
extern NSString *const DatabaseManagerTransactionIsCoinbase;
/// integer, = inputs value - outpus value
extern NSString *const DatabaseManagerTransactionFee;
/// integer -1 (unconfirmed) or > -1
extern NSString *const DatabaseManagerTransactionColBlockHeight;
/// date optional
extern NSString *const DatabaseManagerTransactionColBlockDate;
/// integer
extern NSString *const DatabaseManagerTransactionSize;
/// integer
extern NSString *const DatabaseManagerTransactionVersion;
/// integer
extern NSString *const DatabaseManagerTransactionInputsValue;
/// integer
extern NSString *const DatabaseManagerTransactionInputsCount;
/// string (array json)
extern NSString *const DatabaseManagerTransactionInputs;
/// integer
extern NSString *const DatabaseManagerTransactionOutputsValue;
/// integer
extern NSString *const DatabaseManagerTransactionOutputsCount;
/// string (array json)
extern NSString *const DatabaseManagerTransactionOutputs;
/// integer
extern NSString *const DatabaseManagerTransactionAccountIDX;

/// 完整交易，包含输入输出内容，并有交易归属账户的 idx，用于在 dashboard 显示
@interface CBWDatabaseManager (Transaction)

- (void)transactionFetchWithAccountIDX:(NSInteger)idx completion:(void(^)(NSArray *response))completion;

- (void)transactionSave:(CBWTransaction *)transaction withCompletion:(void (^)(CBWDatabaseChangeType changeType))completion;

@end
