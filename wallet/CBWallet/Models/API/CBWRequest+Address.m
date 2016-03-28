//
//  CBWRequest+Address.m
//  CBWallet
//
//  Created by Zin on 16/3/28.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRequest+Address.h"

@implementation CBWRequest (Address)

- (void)addressTransactionsWithAddressString:(NSString *)addressString limit:(NSUInteger)limit timestamp:(NSUInteger)timestamp completion:(CBWRequestCompletion)completion {
    NSString *path = [NSString stringWithFormat:@"address/%@", addressString];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (limit > 0) {
        [parameters setObject:@(limit) forKey:@"limit"];
    }
    if (timestamp > 0) {
        [parameters setObject:@(timestamp) forKey:@"timestamp"];
    }
    [self requestWithPath:path parameters:parameters completion:completion];
}

@end
