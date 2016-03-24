//
//  NSString+Helper.m
//  wallet
//
//  Created by Zin on 16/2/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize {
    if (self.length == 0) {
        return CGSizeZero;
    }
    CGSize size = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName: font}
                                     context:nil].size;
    size = CGSizeMake(ceilf(size.width), ceilf(size.height));
    return size;
}

+ (instancetype)randomStringWithLength:(NSUInteger)length {
    if (length == 0) {
        return nil;
    }
    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:length];
    for (NSUInteger i = 0; i < length; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return s;
}

@end
