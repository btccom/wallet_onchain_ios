//
//  Transaction.m
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "Transaction.h"

@implementation Transaction

/// fake data
- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = random() % 2;
        self.relatedAddress = @"1SD1ciWyeDNf26YoAUjSsifQZK1ShFJ2s";
        self.confirmed = random() % 10;
        self.value = random() % 1000000000;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"transaction: %@, %lld satoshi, %ld confirmed", self.relatedAddress, self.value, self.confirmed];
}

@end
