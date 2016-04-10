//
//  Recipient.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRecipient.h"

@implementation CBWRecipient

/// init fake data
- (instancetype)init {
    self = [super init];
    if (self) {
        _address = [NSString stringWithFormat:@"1FakeAddress%lld", (long long)random()%100000000000];
        _label = [NSString stringWithFormat:@"Label %ld", random()%10];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"recipient %@: %@", self.label, self.address];
}

@end
