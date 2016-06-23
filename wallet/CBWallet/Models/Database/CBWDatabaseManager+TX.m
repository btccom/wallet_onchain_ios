//
//  CBWDatabaseManager+TX.m
//  CBWallet
//
//  Created by Zin on 16/6/16.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWDatabaseManager+TX.h"

NSString *const DatabaseManagerTableTX = @"tx";

NSString *const DatabaseManagerTXColHash = @"hash";
NSString *const DatabaseManagerTXColValue = @"value";
NSString *const DatabaseManagerTXColBlockHeight = @"blockHeight";
NSString *const DatabaseManagerTXColBlockDate = @"blockDate";
NSString *const DatabaseManagerTXColQueryAddress = @"queryAddress";
NSString *const DatabaseManagerTXColRelatedAddresses = @"relatedAddresses";

@implementation CBWDatabaseManager (TX)

- (void)txFetchWithAccountIDX:(NSInteger)idx completion:(void(^)(NSArray *response))completion {
    
}

- (void)txFetchWithAddressString:(NSString *)addressString completion:(void (^)(NSArray *))completion {
    
}

- (BOOL)txCheck:(CBWTransaction *)transaction {
    return YES;
}

- (void)txSave:(CBWTransaction *)transaction withCompletion:(void (^)(CBWDatabaseChangeType changeType))completion {
    // [self txCheck:transaction];
    completion(CBWDatabaseChangeTypeInsert);
}

@end
