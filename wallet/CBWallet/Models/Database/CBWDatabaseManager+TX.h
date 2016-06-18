//
//  CBWDatabaseManager+TX.h
//  CBWallet
//
//  Created by Zin on 16/6/16.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWDatabaseManager.h"

@class CBWTransaction, CBWTransactionStore;

@interface CBWDatabaseManager (TX)

- (void)txFetchWithAccountIDX:(NSInteger)idx completion:(void(^)(NSArray *response))completion;
- (void)txFetchWithAddressString:(NSString *)addressString completion:(void(^)(NSArray *response))completion;

- (BOOL)txCheck:(CBWTransaction *)transaction;
/// check tx, transaction
///
/// then save(insert or update) transaction, tx
- (void)txSave:(CBWTransaction *)transaction withCompletion:(void (^)(CBWDatabaseChangeType changeType))completion;

@end
