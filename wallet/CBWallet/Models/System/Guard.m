//
//  Guard.m
//  CBWallet
//
//  Created by Zin on 16/3/22.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "Guard.h"

#import "SSKeychain.h"

#import "AESCrypt.h"

static const NSTimeInterval kGuardAvaibleTimeDefault = 10 * 60; // 默认十分钟

@interface Guard ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation Guard

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:kGuardAvaibleTimeDefault target:self selector:@selector(checkOut) userInfo:nil repeats:NO];
    }
    return _timer;
}

+ (instancetype)globalGuard {
    static id staticInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        staticInstance = [[self alloc] init];
    });
    return staticInstance;
}

- (BOOL)checkInWithCode:(NSString *)code {
    NSString *encryptedSeed = [SSKeychain passwordForService:CBWKeyChainSeedService account:CBWKeyChainAccountDefault];
    
    if (encryptedSeed.length > 0) {
        NSString *decryptedSeed = [AESCrypt decrypt:encryptedSeed password:code];
        if (decryptedSeed) {// success
            NSLog(@"welcome");
            // cache code
            _code = code;
            // add timer into run loop
            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            [runLoop addTimer:self.timer forMode:NSDefaultRunLoopMode];
            // return
            return YES;
        }
    }
    
    return NO;
}

- (void)checkOut {
    _code = @"";
    [self.timer invalidate];
    self.timer = nil;
}

@end
