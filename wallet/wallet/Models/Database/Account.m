//
//  Account.m
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "Account.h"

@implementation Account

/// init fake data
- (instancetype)init {
    self = [super init];
    if (self) {
        _label = [NSString stringWithFormat:@"Label %ld", random() % 10];
        _idx = random() % 10;
    }
    return self;
}

+ (instancetype)watchedAccount {
    Account *account = [[super alloc] init];// self has fake data
    account.label = @"Watched Account";
    account.idx = -1;
    return account;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"account %@: idx = %ld", self.label, (long)self.idx];
}

@end
