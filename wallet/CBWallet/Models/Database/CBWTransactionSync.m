//
//  CBWTransactionSync.m
//  CBWallet
//
//  Created by Zin on 16/6/23.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWTransactionSync.h"

#import "CBWRequest.h"

#import "CBWAddress.h"
#import "CBWTransaction.h"

#import "CBWDatabaseManager.h"

#define pullTXNextAddressOrComplete {\
NSDictionary *updatedAddressInfo = @{CBWTransactionSyncInsertedCountKey: @(inserted),\
CBWTransactionSyncConfirmedCountKey: @(updated)};\
[mutableUpdatedAddresses setObject:updatedAddressInfo forKey:responsedAddress.address];\
\
if (addresses.count > 1) {\
    NSMutableArray *lastAddresses = [addresses mutableCopy];\
    [lastAddresses removeLastObject];\
    [self p_pullTXsWithAddresses:[lastAddresses copy] updatedAddresses:[mutableUpdatedAddresses copy] progress:progress completion:completion];\
} else {\
    completion(nil, [mutableUpdatedAddresses copy]);\
}}

NSString *const CBWTransactionSyncInsertedCountKey = @"insertedCount";
NSString *const CBWTransactionSyncConfirmedCountKey = @"confirmedCount";

@implementation CBWTransactionSync

- (void)syncWithAddresses:(NSArray<NSString *> *)addresses progress:(syncProgressBlock)progress completion:(syncCompletionBlock)completion {
    // 1. fetch address summary
    double totalRound = ceil(addresses.count / 50.0);
    DLog(@"sync address summary need %f round", totalRound);
    if (totalRound == 0) {
        completion([NSError errorWithDomain:CBWErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"Error none_address_need_sync", @"CBW", nil)}], nil);
        return;
    }
    
    __block double currentRound = 0;
    __block NSMutableArray<CBWAddress *> *responsedAddresses = [NSMutableArray array];
    CBWRequest *request = [[CBWRequest alloc] init];
    [request addressSummariesWithAddressStrings:addresses completion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
        
        // parse response
        NSArray *parsedAddresses = [CBWAddress batchInitWithArray:response];
        if (parsedAddresses.count > 0) {
            [responsedAddresses addObjectsFromArray:parsedAddresses];
        }
        DLog(@"responsed addresses: \n%@", responsedAddresses);
        
        // check round
        currentRound += 1.0;
        
        // progress
        progress([NSString stringWithFormat:NSLocalizedStringFromTable(@"Message TransactionSync progresss_address_summary_percent_%f", @"CBW", nil), 100.0 * currentRound / totalRound]);
        
        DLog(@"sync address summary current round %f", currentRound);
        if (currentRound == totalRound) {// 1. end
            // progress
            progress(NSLocalizedStringFromTable(@"Message TransactionSync progress_compare_addresses_to_sync", @"CBW", nil));
            // 2. detect which address need to be updated
            NSArray<NSArray<CBWAddress *> *> *comparedAddresses = [self p_compareLocalTXWithAddresses:[responsedAddresses copy]];
            DLog(@"updated addresses count: %lu", (unsigned long)comparedAddresses.count);
            if (comparedAddresses.count > 0) {
                // 3. pull tx address by address
                [self p_pullTXsWithAddresses:comparedAddresses updatedAddresses:nil progress:progress completion:completion];
            }
        }
    }];
}

- (NSArray<NSArray<CBWAddress *> *> *)p_compareLocalTXWithAddresses:(NSArray<CBWAddress *> *)addresses {
    __block NSMutableArray<NSArray<CBWAddress *> *> *comparedAddress = [NSMutableArray array];
    
    [addresses enumerateObjectsUsingBlock:^(CBWAddress * _Nonnull address, NSUInteger idx, BOOL * _Nonnull stop) {
        [[CBWDatabaseManager defaultManager] txFetchWithQueryAddress:address.address completion:^(NSArray *response) {
            DLog(@"local tx count [%lu] for address: %@", (unsigned long)response.count, address.address);
            NSArray<CBWTransaction *> *txs = [CBWTransaction batchInitWithArray:response];
            CBWTransaction *firstTX = [txs firstObject];
            CBWTransaction *lastTX = [txs lastObject];
            __block NSInteger unconfirmedTXCount = 0;
            __block CBWTransaction *firstUnconfirmedTX = nil;
            [txs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(CBWTransaction * _Nonnull tx, NSUInteger idx, BOOL * _Nonnull stop) {
                if (-1 == tx.blockHeight) {
                    unconfirmedTXCount ++;
                    firstUnconfirmedTX = tx;
                }
            }];
            if (![address.firstTXHashID isEqualToString:firstTX.hashID] ||
                ![address.lastTXHashID isEqualToString:lastTX.hashID] ||
                !(address.unconfirmedTXCount == unconfirmedTXCount)) {
                CBWAddress *localAddress = [[CBWAddress alloc] initWithDictionary:@{@"address": address.address}];
                localAddress.firstTXHashID = firstTX.hashID;
                localAddress.lastTXHashID = lastTX.hashID;
                localAddress.firstUnconfirmedTXHashID = firstUnconfirmedTX.hashID;
                localAddress.unconfirmedTXCount = unconfirmedTXCount;
                [comparedAddress addObject:@[address, localAddress]];
            }
        }];
    }];
    
    return [comparedAddress copy];
};

/// 逐个地址去拉取交易
- (void)p_pullTXsWithAddresses:(NSArray<NSArray<CBWAddress *> *> *)addresses updatedAddresses:(NSDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *)updatedAddresses progress:(syncProgressBlock)progress completion:(syncCompletionBlock)completion {
    
    NSArray<CBWAddress *> *lastObject = [addresses lastObject];
    CBWAddress *responsedAddress = [lastObject firstObject];
    CBWAddress *localAddress = [lastObject lastObject];
    
    __block NSMutableDictionary *mutableUpdatedAddresses = [updatedAddresses mutableCopy];
    if (!mutableUpdatedAddresses) {
        mutableUpdatedAddresses = [NSMutableDictionary dictionaryWithCapacity:addresses.count];
    }
    
    // detect how to fetch address's tx
    if (![responsedAddress.firstTXHashID isEqualToString:localAddress.firstTXHashID]) {
        
        progress([NSString stringWithFormat:NSLocalizedStringFromTable(@"Message TransactionSync progress_fetch_all_tx_address_%@", @"CBW", nil), responsedAddress.address]);
        
        // fetch all
        __block NSInteger updated = 0;
        __block NSInteger inserted = 0;
        CBWRequest *request = [CBWRequest new];
        [request addressTransactionsWithAddressString:responsedAddress.address page:0 pagesize:0 checkCompletion:^BOOL(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
            NSArray *list = [response objectForKey:CBWRequestResponseDataListKey];
            [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CBWTransaction *transaction = nil;
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    // transaction table
                    NSString *hash = [obj objectForKey:@"hash"];
                    transaction = [[CBWDatabaseManager defaultManager] transactionWithHash:hash];
                    if (transaction && transaction.blockHeight == -1) {
                        // update transaction
                        [transaction setValuesForKeysWithDictionary:obj];
                        if ([[CBWDatabaseManager defaultManager] transactionUpdateTransaction:transaction]) {
                            updated ++;
                        }
                    } else {
                        transaction = [[CBWTransaction alloc] initWithDictionary:obj];
                        if (transaction && [[CBWDatabaseManager defaultManager] transactionInsertTransaction:transaction]) {
                            inserted ++;
                        }
                    }
                    // tx table
                    if (transaction) {
                        [[CBWDatabaseManager defaultManager] txSave:transaction withCompletion:^(CBWDatabaseChangeType changeType) {}];
                    }
                }
            }];
            
            // check page
            double totalCount = [[response objectForKey:CBWRequestResponseDataTotalCountKey] doubleValue];
            double pagesize = [[response objectForKey:CBWRequestResponseDataPageSizeKey] doubleValue];
            NSUInteger totalPage = ceil(totalCount / pagesize);
            NSUInteger page = [[response objectForKey:CBWRequestResponseDataPageKey] unsignedIntegerValue];
            
            progress([NSString stringWithFormat:NSLocalizedStringFromTable(@"Message TransactionSync progress_fetch_all_tx_address_%@_%lu_%lu", @"CBW", nil), responsedAddress.address, (unsigned long)page, (unsigned long)totalPage]);
            
            if (totalPage == page) {
                // update and next address
                pullTXNextAddressOrComplete;
                return YES;// the last page
            }
            return NO;// next page
        }];
    } else {
        if (localAddress.unconfirmedTXCount > 0) {
            
            progress([NSString stringWithFormat:NSLocalizedStringFromTable(@"Message TransactionSync progress_fetch_to_unconfirmed_tx_address_%@", @"CBW", nil), responsedAddress.address]);
            
            // fetch to the local unconfirmed tx
            __block NSInteger updated = 0;
            __block NSInteger inserted = 0;
            CBWRequest *request = [CBWRequest new];
            [request addressTransactionsWithAddressString:responsedAddress.address page:0 pagesize:0 checkCompletion:^BOOL(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
                
                __block BOOL touchedTheUnconfirmedTX = NO;
                NSArray *list = [response objectForKey:CBWRequestResponseDataListKey];
                [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    CBWTransaction *transaction = nil;
                    if ([obj isKindOfClass:[NSDictionary class]]) {
                        // transaction table
                        NSString *hash = [obj objectForKey:@"hash"];
                        transaction = [[CBWDatabaseManager defaultManager] transactionWithHash:hash];
                        if (transaction && transaction.blockHeight == -1) {
                            // update transaction
                            [transaction setValuesForKeysWithDictionary:obj];
                            if ([[CBWDatabaseManager defaultManager] transactionUpdateTransaction:transaction]) {
                                updated ++;
                            }
                        } else {
                            transaction = [[CBWTransaction alloc] initWithDictionary:obj];
                            if (transaction && [[CBWDatabaseManager defaultManager] transactionInsertTransaction:transaction]) {
                                inserted ++;
                            }
                        }
                        // tx table
                        if (transaction) {
                            [[CBWDatabaseManager defaultManager] txSave:transaction withCompletion:^(CBWDatabaseChangeType changeType) {}];
                        }
                        if ([hash isEqualToString:localAddress.firstUnconfirmedTXHashID]) {
                            touchedTheUnconfirmedTX = YES;
                            *stop = YES;
                        }
                    }
                }];
                if (touchedTheUnconfirmedTX) {
                    // update and next address
                    pullTXNextAddressOrComplete;
                    return YES;// to the first unconfirmed tx
                }
                
                progress([NSString stringWithFormat:NSLocalizedStringFromTable(@"Message TransactionSync progress_fetch_to_unconfirmed_tx_address_%@_next_page", @"CBW", nil), responsedAddress.address]);
                
                return NO;// next page
            }];
        } else {
            
            progress([NSString stringWithFormat:NSLocalizedStringFromTable(@"Message TransactionSync progress_fetch_to_last_tx_address_%@", @"CBW", nil), responsedAddress.address]);
        
            // the last tx is not same
            // just fetch to the last tx
            __block NSInteger updated = 0;
            __block NSInteger inserted = 0;
            CBWRequest *request = [CBWRequest new];
            [request addressTransactionsWithAddressString:responsedAddress.address page:0 pagesize:0 checkCompletion:^BOOL(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
                
                __block BOOL touchedTheLastTX = NO;
                NSArray *list = [response objectForKey:CBWRequestResponseDataListKey];
                [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    CBWTransaction *transaction = nil;
                    if ([obj isKindOfClass:[NSDictionary class]]) {
                        // transaction table
                        NSString *hash = [obj objectForKey:@"hash"];
                        transaction = [[CBWDatabaseManager defaultManager] transactionWithHash:hash];
                        if (transaction && transaction.blockHeight == -1) {
                            // update transaction
                            [transaction setValuesForKeysWithDictionary:obj];
                            if ([[CBWDatabaseManager defaultManager] transactionUpdateTransaction:transaction]) {
                                updated ++;
                            }
                        } else {
                            transaction = [[CBWTransaction alloc] initWithDictionary:obj];
                            if (transaction && [[CBWDatabaseManager defaultManager] transactionInsertTransaction:transaction]) {
                                inserted ++;
                            }
                        }
                        // tx table
                        if (transaction) {
                            [[CBWDatabaseManager defaultManager] txSave:transaction withCompletion:^(CBWDatabaseChangeType changeType) {}];
                        }
                        if ([hash isEqualToString:localAddress.lastTXHashID]) {
                            touchedTheLastTX = YES;
                            *stop = YES;
                        }
                    }
                }];
                if (touchedTheLastTX) {
                    // update and next address
                    pullTXNextAddressOrComplete;
                    return YES;// to the first unconfirmed tx
                }
                
                progress([NSString stringWithFormat:NSLocalizedStringFromTable(@"Message TransactionSync progress_fetch_to_last_tx_address_%@_next_page", @"CBW", nil), responsedAddress.address]);
                
                return NO;// next page
            }];
        }
    }
}

@end