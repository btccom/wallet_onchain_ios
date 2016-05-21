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
    long long value = self.longLongValue;
    return [NSString stringWithFormat:@"%.8lf BTC", value / 100000000.0];
}

- (NSString *)satoshimBTCString {
    long long value = self.longLongValue;
    return [NSString stringWithFormat:@"%.5lf mBTC", value / 100000.0];
}

- (NSString *)satoshimmBTCString {
    long long value = self.longLongValue;
    return [NSString stringWithFormat:@"%.2lf μMTC", value / 100.0];
}

@end
