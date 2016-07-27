//
//  UIFont+CBW.m
//  CBWallet
//
//  Created by Zin on 16/3/29.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "UIFont+CBW.h"

@implementation UIFont (CBW)
+ (instancetype)monospacedFontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"Courier" size:size];
}
@end
