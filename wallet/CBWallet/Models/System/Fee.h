//
//  Fee.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/7.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FeeLevel) {
    FeeLevelCustom = -1,
    FeeLevelLow,
    FeeLevelMedium,
    FeeLevelHigh
};

@interface Fee : NSObject

@property (nonatomic, assign, readonly) FeeLevel level;
/// long long value in satoshi
@property (nonatomic, strong, readonly) NSNumber *value;

+ (instancetype)defaultFee;
+ (instancetype)feeWithLevel:(FeeLevel)level;
/// value in satoshi
+ (instancetype)feeWithValue:(NSNumber *)value;
+ (NSArray *)values;

@end
