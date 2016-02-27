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
    CGSize size = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName: font}
                                     context:nil].size;
    size = CGSizeMake(roundf(size.width), roundf(size.height));
    return size;
}

@end
