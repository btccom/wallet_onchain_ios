//
//  CBWRequest+Address.m
//  CBWallet
//
//  Created by Zin on 16/3/28.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRequest+Address.h"

@implementation CBWRequest (Address)

- (void)addressSummaryWithAddressString:(NSString *)addressString completion:(CBWRequestCompletion)completion {
    NSString *path = [NSString stringWithFormat:@"address/%@", addressString];
    [self requestWithPath:path parameters:nil completion:completion];
}

- (void)addressSummariesWithAddressStrings:(NSArray *)addressStrings completion:(CBWRequestCompletion)completion {
    NSString *addresses = [addressStrings componentsJoinedByString:@","];
    NSString *path = [NSString stringWithFormat:@"address/%@", addresses];
    [self requestWithPath:path parameters:nil completion:completion];
}

- (void)addressTransactionsWithAddressString:(NSString *)addressString page:(NSUInteger)page pagesize:(NSUInteger)pagesize completion:(CBWRequestCompletion)completion {
    NSString *path = [NSString stringWithFormat:@"address/%@/tx", addressString];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (pagesize > 0) {
        [parameters setObject:@(pagesize) forKey:CBWRequestResponseDataPageSizeKey];
    }
    if (page > 0) {
        [parameters setObject:@(page) forKey:CBWRequestResponseDataPageKey];
    }
    [self requestWithPath:path parameters:parameters completion:completion];
}

// TODO: 改用 delegate 方式，可以增量的更新数据
- (void)addressTransactionsWithAddressStrings:(NSArray *)addressStrings completion:(void (^ _Nullable)(NSError * _Nullable, NSInteger, id _Nullable, NSString * _Nonnull))completion {
    if ([addressStrings isKindOfClass:[NSArray class]]) {
        if (addressStrings.count > 0) {
            NSString *addressString = [addressStrings firstObject];
            NSMutableArray *lastAddressStrings = [addressStrings mutableCopy];
            [lastAddressStrings removeObject:addressString];
            [self addressTransactionsWithAddressString:addressString page:0 pagesize:10 completion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
                // callback
                completion(error, statusCode, response, addressString);
                if (!error && lastAddressStrings.count > 0) {
                    // next round
                    [self addressTransactionsWithAddressStrings:[lastAddressStrings copy] completion:completion];
                }
            }];
        }
    }
}

- (void)addressUnspentWithAddressString:(NSString *)addressString unspentHolder:(nonnull NSArray *)unspentHolder page:(NSUInteger)page completion:(nullable CBWRequestCompletion)completion {
    NSString *path = [NSString stringWithFormat:@"address/%@/unspent", addressString];
    NSDictionary *parameters = @{CBWRequestResponseDataPageKey: @(page)};
    [self requestWithPath:path parameters:parameters completion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
        if (error) {
            completion(error, statusCode, response);
        } else {
            NSMutableArray *unspent = [unspentHolder mutableCopy];
            [unspent addObjectsFromArray:[response objectForKey:CBWRequestResponseDataListKey]];
            
            NSUInteger totalCount = [[response objectForKey:CBWRequestResponseDataTotalCountKey] unsignedIntegerValue];
            NSUInteger pageSize = [[response objectForKey:CBWRequestResponseDataPageSizeKey] unsignedIntegerValue];
            NSUInteger page = [[response objectForKey:CBWRequestResponseDataPageKey] unsignedIntegerValue];
            
            if (pageSize * page < totalCount) {
                // 继续
                [self addressUnspentWithAddressString:addressString unspentHolder:[unspent copy] page:(page + 1) completion:completion];
            } else {
                completion(error, statusCode, [unspent copy]);
            }
        }
    }];
}

- (void)addressesUnspentForAddresses:(NSArray *)addresses withAmount:(long long)amount progress:(void (^ _Nullable)(NSString * _Nonnull))progress completion:(void (^ _Nullable)(NSError * _Nullable, NSArray * _Nullable))completion {
    [addresses enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 依次获取地址未花
        if ([obj isKindOfClass:[NSString class]]) {
            // 仍未地址文本，未赋值
            NSString *addressString = obj;
            // 获取改地址未花交易记录
            progress([NSString stringWithFormat:NSLocalizedStringFromTable(@"Message unspent_fetch %@", @"CBW", nil), addressString]);
            [self addressUnspentWithAddressString:addressString unspentHolder:[NSArray array] page:0 completion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
                if (error) {
                    progress(NSLocalizedStringFromTable(@"Message unspent_fetch_failed", @"CBW", nil));
                    // 出现失败即退出
                    completion(error, nil);
                } else {
                    progress(NSLocalizedStringFromTable(@"Message unspent_fetch_successful", @"CBW", nil));
                    NSArray *unspentTxs = response;
                    DLog(@"unspent tx total: %ld", (unsigned long)unspentTxs.count);
                    // 设置记录
                    NSMutableArray *newAddresses = [addresses mutableCopy];
                    [newAddresses setObject:@{addressString: unspentTxs} atIndexedSubscript:idx];// unspentTxs = response = new unspentHolder
                    // 计算未花交易总量
                    __block long long unspentAmount = 0;
                    [unspentTxs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSDictionary *tx = obj;
                        unspentAmount += [[tx objectForKey:@"value"] longLongValue];
                    }];
                    DLog(@"unspent amount: %lld", unspentAmount);
                    // 比较
                    long long lastAmount = amount - unspentAmount;
                    if (lastAmount > 0) {
                        // 额度不够
                        if (idx < addresses.count - 1) {
                            // 不是最后一个地址，继续
                            progress(NSLocalizedStringFromTable(@"Message unspent_fetch_next", @"CBW", nil));
                            [self addressesUnspentForAddresses:newAddresses withAmount:lastAmount progress:progress completion:completion];
                        } else {
                            // 否则，返回额度不足的错误
                            NSError *notEnoughError = [[NSError alloc] initWithDomain:CBWRequestErrorDomain code:CBWRequestErrorCodeNotEnoughBalance userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"Error not_enough_balance", @"CBW", nil)}];
                            completion(notEnoughError, nil);
                        }
                    } else {
                        completion(nil, [newAddresses copy]);
                    }
                }
            }];
            *stop = YES;
        }
    }];
}

@end
