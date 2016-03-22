//
//  Guard.m
//  CBWallet
//
//  Created by Zin on 16/3/22.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "Guard.h"
#import <CommonCrypto/CommonCrypto.h>

@interface Guard ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation Guard

+ (instancetype)globalGuard {
    static id staticInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        staticInstance = [[self alloc] init];
    });
    return staticInstance;
}

- (BOOL)checkInWithCode:(NSString *)code {
//    _code = code;
    
    return NO;
}

- (void)checkOut {
    _code = @"";
    [self.timer invalidate];
}

@end
