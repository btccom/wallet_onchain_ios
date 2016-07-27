//
//  NSNull+SafePatch.m
//  CBWallet
//
//  Created by Zin on 16/3/31.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "NSNull+SafePatch.h"

@implementation NSNull (SafePatch)

- (long long)longlongValue {
    [self p_log];
    return 0;
}

- (NSUInteger)unsignedIntegerValue {
    [self p_log];
    return 0;
}

- (NSInteger)integerValue {
    [self p_log];
    return 0;
}

- (BOOL)boolValue {
    [self p_log];
    return NO;
}

- (id)objectAtIndex:(NSUInteger)index {
    [self p_log];
    return nil;
}

- (id)objectForKey:(NSString *)key {
    [self p_log];
    return nil;
}

- (NSUInteger)count {
    [self p_log];
    return 0;
}

- (NSUInteger)length {
    [self p_log];
    return 0;
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    return;
}

- (void)p_log {
    NSLog(@"call NSNull unrecognized method");
}

@end
