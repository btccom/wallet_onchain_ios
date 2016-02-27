//
//  NSString+BTCCAddress.m
//  wallet
//
//  Created by Zin on 16/2/27.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "NSString+BTCCAddress.h"

@implementation NSString (BTCCAddress)

- (NSAttributedString *)attributedAddressWithAlignment:(NSTextAlignment)alignment {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = alignment;
    paragraph.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, [attributedString length])];
    return attributedString;
}

@end
