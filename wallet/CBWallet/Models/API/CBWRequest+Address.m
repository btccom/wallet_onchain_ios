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

- (void)addressTransactionsWithAddressString:(NSString *)addressString page:(NSUInteger)page pagesize:(NSUInteger)pagesize completion:(CBWRequestCompletion)completion {
    NSString *path = [NSString stringWithFormat:@"address/%@/tx", addressString];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:@(CBWRequestPageSizeDefault) forKey:@"pagesize"];
    if (pagesize > 0) {
        [parameters setObject:@(pagesize) forKey:@"pagesize"];
    }
    if (page > 0) {
        [parameters setObject:@(page) forKey:@"page"];
    }
    [self requestWithPath:path parameters:parameters completion:completion];
}

- (void)addressUnspentWithAddressString:(NSString *)addressString completion:(CBWRequestCompletion)completion {
    NSString *path = [NSString stringWithFormat:@"address/%@/unspent", addressString];
    [self requestWithPath:path parameters:nil completion:completion];
}

@end
