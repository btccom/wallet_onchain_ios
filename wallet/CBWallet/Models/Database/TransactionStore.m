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
    [records removeAllObjects];
    [self loadCache];
}

- (void)loadCache {
    
}

- (void)addTransactionsFromJsonObject:(id)jsonObject {
    if (!self.isUpToDate) {
        // 缓存
    }
    _upToDate = NO;
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        
    }
}

@end
