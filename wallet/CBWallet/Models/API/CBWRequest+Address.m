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
        [parameters setObject:@(pagesize) forKey:@"pagesize"];
    }
    if (page > 0) {
        [parameters setObject:@(page) forKey:@"page"];
    }
    [self requestWithPath:path parameters:parameters completion:completion];
}

- (void)addressTransactionsWithAddressStrings:(NSArray *)addressStrings completion:(CBWRequestCompletion)completion {
    if ([addressStrings isKindOfClass:[NSArray class]]) {
        if (addressStrings.count > 0) {
            NSString *addressString = [addressStrings firstObject];
            NSMutableArray *lastAddressStrings = [addressStrings mutableCopy];
            [lastAddressStrings removeObject:addressString];
            [self addressTransactionsWithAddressString:addressString page:0 pagesize:0 completion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
                // callback
                completion(error, statusCode, response);
                // next round
                [self addressTransactionsWithAddressStrings:[lastAddressStrings copy] completion:completion];
            }];
        }
    }
}

- (void)addressUnspentWithAddressString:(NSString *)addressString completion:(CBWRequestCompletion)completion {
    NSString *path = [NSString stringWithFormat:@"address/%@/unspent", addressString];
    [self requestWithPath:path parameters:nil completion:completion];
}

@end
