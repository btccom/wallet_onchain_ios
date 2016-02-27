//
//  Recipient.m
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "Recipient.h"

@implementation Recipient

/// init fake data
- (instancetype)init {
    self = [super init];
    if (self) {
        _address = [NSString stringWithFormat:@"1FakeAddress%ld", random()%100000000000];
        _label = [NSString stringWithFormat:@"Label %ld", random()%10];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"recipient %@: %@", self.label, self.address];
}

@end
