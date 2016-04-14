//
//  TransactionStore.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWTransactionStore.h"
#import "CBWAccount.h"

@implementation CBWTransactionStore

- (instancetype)initWithAddressString:(NSString *)addressString {
    self = [super init];
    if (self) {
        _addressString = [addressString copy];
    }
    return self;
}

- (void)fetch {
    [super fetch];
    [self loadCache];
}

- (void)loadCache {
    NSString *path = [self p_cachedPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *cachedData = [NSData dataWithContentsOfFile:path];
        NSError *error = nil;
        NSArray *array = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"load transaction cache error: %@", error);
            return;
        }
        if (array.count > 0) {
            [self p_parseTransactionsWithArray:array];
        }
    }
}

- (void)flush {
    [super flush];
}

- (void)addTransactionsFromJsonObject:(id)jsonObject isCacheNeeded:(BOOL)isCacheNeeded {
    if (isCacheNeeded) {
//        [self flush];
        [self p_cacheJsonObject:jsonObject];
    }
    
    [self p_parseTransactionsWithArray:jsonObject];
}

- (void)sort {
    [records sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        CBWTransaction *t1 = obj1;
        CBWTransaction *t2 = obj2;
        return [t2.creationDate compare:t1.creationDate];// DESC
    }];
}

#pragma - Private Method

- (NSString *)p_cachedPath {
    NSString *fileName = self.addressString;
    if (!fileName) {
        fileName = [NSString stringWithFormat:@"account-%ld", self.account.idx];
    }
    NSString *cacheFileName = [NSString stringWithFormat:@"%@%@%@", CBWCacheTransactionPrefix, fileName, CBWCacheSubfix];
    return [CBWCachePath() stringByAppendingPathComponent:cacheFileName];
}

- (void)p_cacheJsonObject:(id)jsonObject {
    NSError *error = nil;
    NSData *cachedData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"json object to data error: %@", error);
        return;
    }
    
    if (![cachedData writeToFile:[self p_cachedPath] options:NSDataWritingAtomic error:&error]) {
        NSLog(@"cache transaction failed: %@", error);
    }
}

- (void)p_parseTransactionsWithArray:(id)array {
    if (![array isKindOfClass:[NSArray class]]) {
        return;
    }
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CBWTransaction *transaction = [[CBWTransaction alloc] initWithDictionary:obj];
        [self addRecord:transaction ASC:YES];
    }];
}

@end
