//
//  CBWRequest+Transaction.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/31.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRequest+Transaction.h"

@implementation CBWRequest (Transaction)

- (void)transactionWithHash:(NSString *)hash completion:(CBWRequestCompletion)completion {
    NSString *path = [NSString stringWithFormat:@"tx/%@", hash];
    [self requestWithPath:path parameters:@{@"verbose": @3} completion:completion];
}

- (void)transactionsWithHashes:(NSArray *)hashes completion:(CBWRequestCompletion)completion {
    NSString *hashesString = [hashes componentsJoinedByString:@","];
    NSString *path = [NSString stringWithFormat:@"tx/%@", hashesString];
    [self requestWithPath:path parameters:@{@"verbose": @3} completion:completion];
}

@end
