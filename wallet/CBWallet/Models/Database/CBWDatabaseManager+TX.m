//
//  CBWDatabaseManager+TX.m
//  CBWallet
//
//  Created by Zin on 16/6/16.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWDatabaseManager+TX.h"

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
