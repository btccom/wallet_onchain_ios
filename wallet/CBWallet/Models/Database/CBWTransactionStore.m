//
//  TransactionStore.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWTransactionStore.h"

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
    
}

- (void)flush {
    [super flush];
    _upToDate = NO;
}

- (void)addTransactionsFromJsonObject:(id)jsonObject {
    if (self.addressString) {
        if (!self.isUpToDate) {
            // 缓存
        }
        _upToDate = YES;
    } else {
        // 直接缓存
    }
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        [jsonObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Transaction *transaction = [[Transaction alloc] initWithDictionary:obj];
            [self addRecord:transaction ASC:YES];
        }];
    }
}

- (void)sort {
    [records sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        Transaction *t1 = obj1;
        Transaction *t2 = obj2;
        return [t2.creationDate compare:t1.creationDate];// DESC
    }];
}

@end
