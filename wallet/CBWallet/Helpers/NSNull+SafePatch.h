//
//  NSNull+SafePatch.h
//  CBWallet
//
//  Created by Zin on 16/3/31.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNull (SafePatch)

- (long long)longlongValue;
- (NSUInteger)unsignedIntegerValue;
- (NSInteger)integerValue;
- (BOOL)boolValue;
- (id)objectAtIndex:(NSUInteger)index;
- (id)objectForKey:(NSString *)key;
- (NSUInteger)count;
- (NSUInteger)length;
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block NS_AVAILABLE(10_6, 4_0);

@end
