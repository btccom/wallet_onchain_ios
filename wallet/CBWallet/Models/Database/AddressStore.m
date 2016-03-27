//
//  AddressStore.m
//  CBWallet
//
//  Created by Zin on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AddressStore.h"
#import "DatabaseManager.h"

@implementation AddressStore

- (instancetype)initWithAccountIdx:(NSInteger)accountIdx {
    self = [super init];
    if (self) {
        _accountIdx = accountIdx;
    }
    return self;
}

- (void)fetch {
    [records removeAllObjects];
    if (self.isArchived) {
        [[DatabaseManager defaultManager] fetchAddressWithAccountIdx:self.accountIdx archived:YES toStore:self];
        return;
    }
    [[DatabaseManager defaultManager] fetchAddressWithAccountIdx:self.accountIdx toStore:self];
}

- (NSUInteger)countAllAddresses {
    return [[DatabaseManager defaultManager] countAllAddressesWithAccountIdx:self.accountIdx];
}

@end
