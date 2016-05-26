//
//  NSNumber+Helper.m
//  CBWallet
//
//  Created by Zin on 16/5/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "NSNumber+Helper.h"

@implementation NSNumber (Helper)

- (NSString *)groupingString {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    numberFormatter.usesGroupingSeparator = YES;
    return [numberFormatter stringFromNumber:self];
}

@end
