//
//  TransactionStore.m
//  CBWallet
//
//  Created by Zin on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "TransactionStore.h"

@implementation TransactionStore

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
    DLog(@"add transactions from json object: %@", jsonObject);
    if (!self.isUpToDate) {
        // 缓存
    }
    _upToDate = YES;
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        [jsonObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Transaction *transaction = [[Transaction alloc] initWithDictionary:obj];
            [self addRecord:transaction];
        }];
    }
}

@end
