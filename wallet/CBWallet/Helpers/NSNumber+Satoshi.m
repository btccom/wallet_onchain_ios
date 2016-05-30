//
//  NSNumber+Satoshi.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/5.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "NSNumber+Satoshi.h"

@implementation NSNumber (Satoshi)

- (NSString *)satoshiBTCString {
    return [self p_formatWithDigitsNumber:8 unit:@"BTC"];
    
    //[NSString stringWithFormat:@"%.8lf BTC", value / 100000000.0];
}

- (NSString *)satoshimBTCString {
    return [self p_formatWithDigitsNumber:5 unit:@"mBTC"];
}

- (NSString *)satoshimmBTCString {
    return [self p_formatWithDigitsNumber:2 unit:@"μBTC"];
}

- (NSString *)p_formatWithDigitsNumber:(NSUInteger)number unit:(NSString *)unit {
    long long value = self.longLongValue;
    
    if (value == 0) {
        return [NSString stringWithFormat:@"0 %@", unit];
    }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    numberFormatter.usesGroupingSeparator = YES;
    [numberFormatter setMaximumFractionDigits:number];
    [numberFormatter setMinimumFractionDigits:number];
    
    return [NSString stringWithFormat:@"%@ %@", [numberFormatter stringFromNumber:@(value / pow(10, number))], unit];
}

@end
