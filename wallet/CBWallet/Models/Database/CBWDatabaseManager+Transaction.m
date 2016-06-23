//
//  CBWDatabaseManager+Transaction.m
//  CBWallet
//
//  Created by Zin on 16/6/23.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWDatabaseManager+Transaction.h"

NSString *const DatabaseManagerTableTransaction = @"transaction";

NSString *const DatabaseManagerTransactionColHash = @"hash";
NSString *const DatabaseManagerTransactionIsCoinbase = @"isCoinbase";
NSString *const DatabaseManagerTransactionFee = @"fee";
NSString *const DatabaseManagerTransactionColBlockHeight = @"blockHeight";
NSString *const DatabaseManagerTransactionColBlockDate = @"blockDate";
NSString *const DatabaseManagerTransactionSize = @"size";
NSString *const DatabaseManagerTransactionVersion = @"version";
NSString *const DatabaseManagerTransactionInputsValue = @"inputsValue";
NSString *const DatabaseManagerTransactionInputsCount = @"inputsCount";
NSString *const DatabaseManagerTransactionInputs = @"inputs";
NSString *const DatabaseManagerTransactionOutputsValue = @"outputsValue";
NSString *const DatabaseManagerTransactionOutputsCount = @"outputsCount";
NSString *const DatabaseManagerTransactionOutputs = @"outputs";
NSString *const DatabaseManagerTransactionAccountIDX = @"accountIDX";

@implementation CBWDatabaseManager (Transaction)

- (void)transactionFetchWithAccountIDX:(NSInteger)idx completion:(void (^)(NSArray *))completion {}

- (void)transactionSave:(CBWTransaction *)transaction withCompletion:(void (^)(CBWDatabaseChangeType))completion {}

@end
