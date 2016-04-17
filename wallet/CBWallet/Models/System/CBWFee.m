//
//  Fee.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/7.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWFee.h"

@interface CBWFee ()

@property (nonatomic, assign, readwrite) CBWFeeLevel level;
@property (nonatomic, strong, readwrite) NSNumber *value;

@end

@implementation CBWFee

+ (instancetype)defaultFee {
    return [self feeWithLevel:CBWFeeLevelMedium];
}

+ (instancetype)feeWithLevel:(CBWFeeLevel)level {
    CBWFee *fee = [[self alloc] init];
    fee.level = level;
    return fee;
}

+ (instancetype)feeWithValue:(NSNumber *)value {
    CBWFee *fee = [[self alloc] init];
    fee.level = CBWFeeLevelCustom;
    fee.value = value;
    return fee;
}

- (NSNumber *)value {
    if (!_value) {
        if (self.level >= 0) {
            _value = [CBWFee.values objectAtIndex:self.level];
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
