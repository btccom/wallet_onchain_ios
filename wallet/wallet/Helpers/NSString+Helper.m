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
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{NSFontAttributeName: font}
                              context:nil].size;
}

@end
