//
//  NSString+Helper.h
//  wallet
//
//  Created by Zin on 16/2/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helper)

- (CGSize)sizeWithFont:(nonnull UIFont *)font maxSize:(CGSize)maxSize;
+ (nullable instancetype)randomStringWithLength:(NSUInteger)length;
- (nullable NSNumber *)numberValue;

@end
