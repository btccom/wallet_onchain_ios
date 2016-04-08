//
//  Fee.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/7.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "Fee.h"

@interface Fee ()

@property (nonatomic, assign, readwrite) FeeLevel level;
@property (nonatomic, strong, readwrite) NSNumber *value;

@end

@implementation Fee

+ (instancetype)defaultFee {
    return [self feeWithLevel:FeeLevelMedium];
}

+ (instancetype)feeWithLevel:(FeeLevel)level {
    Fee *fee = [[self alloc] init];
    fee.level = level;
    return fee;
}

+ (instancetype)feeWithValue:(NSNumber *)value {
    Fee *fee = [[self alloc] init];
    fee.level = FeeLevelCustom;
    fee.value = value;
    return fee;
}

- (NSNumber *)value {
    if (!_value) {
        if (self.level >= 0) {
            _value = [Fee.values objectAtIndex:self.level];
        }
    }
    return _value;
}

- (NSString *)description {
    NSString *rawString = [NSString stringWithFormat:@"Description Fee %ld", (long)self.level];
    return NSLocalizedStringFromTable(rawString, @"CBW", nil);
}

+ (NSArray *)values {
    return @[@1000, @10000, @20000];
}

@end
