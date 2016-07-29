//
//  UILabel+BTCAmount.m
//  CBWallet
//
//  Created by Zin on 16/7/29.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "UILabel+BTCAmount.h"

@implementation UILabel (BTCAmount)

- (void)btc_formatZeroDecimals {
    NSString *string = self.text;
    if (string.length == 0) {
        return;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSString *amount = [[string componentsSeparatedByString:@" "] firstObject];// 1,234.12345600 BTC
    NSUInteger length = amount.length;
    while (length > 0) {
        length --;
        NSString *c = [amount substringWithRange:NSMakeRange(length, 1)];
        if ([c isEqualToString:@"."] || [c integerValue] > 0) {
            break;
        }
    }
    if (length < amount.length - 1) {
        [attributedString setAttributes:@{NSForegroundColorAttributeName: [self.textColor colorWithAlphaComponent:0.3]} range:NSMakeRange(length + 1, amount.length - length - 1)];
    }
    self.attributedText = attributedString;
}

@end
