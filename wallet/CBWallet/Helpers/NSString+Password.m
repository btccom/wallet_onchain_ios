//
//  NSString+Password.m
//  CBWallet
//
//  Created by Zin on 16/3/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "NSString+Password.h"

@implementation NSString (Password)

- (NSInteger)passwordStrength {
    if (self.length == 0) {
        return 0;
    }
    return 100;
}

@end
