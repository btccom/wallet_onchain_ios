//
//  Guard.m
//  CBWallet
//
//  Created by Zin on 16/3/22.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "Guard.h"

#import "SSKeychain.h"

#import "NSString+PBKDF2.h"
#import "NSData+AES256.h"

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
    NSString *uuid = [SSKeychain passwordForService:CBWKeyChainUUIDService account:CBWKeyChainAccountDefault];
    NSLog(@"check in uuid: %@", uuid);
    if (uuid.length > 0) {
        NSData *seed = [SSKeychain passwordDataForService:CBWKeyChainSeedService account:CBWKeyChainAccountDefault];
        NSString *key = [code PBKDF2KeyWithSalt:uuid];
        NSString *decryptedSeed = [[NSString alloc] initWithData:[seed AES256DecryptWithKey:key] encoding:NSUTF8StringEncoding];
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
