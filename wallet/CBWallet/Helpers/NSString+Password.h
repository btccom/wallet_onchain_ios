//
//  NSString+Password.h
//  CBWallet
//
//  Created by Zin on 16/3/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Password)

/// max 100
- (NSInteger)passwordStrength;

@end
