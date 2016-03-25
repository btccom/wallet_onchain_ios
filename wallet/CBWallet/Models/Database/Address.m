//
//  Address.m
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "Address.h"
#import "AddressStore.h"

@implementation Address

/// init fake data
- (instancetype)init {
    self = [super init];
    if (self) {
        _address = [NSString stringWithFormat:@"1FakeAddressWithLongLongNumber%lld", (long long)random() % 100000000000];
        _label = [NSString stringWithFormat:@"Label %ld", random() % 10];
        _balance = random() % 10000000000;
        _txCount = random() % 50;
    }
    return self;
}

- (void)deleteFromStore:(RecordObjectStore *)store {
    DLog(@"will never delete an address");
    return;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"address %@: %@, %lld satoshi", self.label, self.address, self.balance];
}

@end
