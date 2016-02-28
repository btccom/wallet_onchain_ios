//
//  Transaction.m
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "Transaction.h"

@implementation Transaction

/// init fake data
- (instancetype)init {
    self = [super init];
    if (self) {
        _type = random() % 2;
        _relatedAddress = @"1SD1ciWyeDNf26YoAUjSsifQZK1ShFJ2s";
        _confirmed = random() % 10;
        _value = random() % 10000000000;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"transaction, related address %@, %lld satoshi, %ld confirmed", self.relatedAddress, self.value, (unsigned long)self.confirmed];
}

@end
