//
//  Guard.m
//  CBWallet
//
//  Created by Zin on 16/3/22.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "Guard.h"
#import "Database.h"
#import "CBWBackup.h"
#import "CBWTransactionStore.h"

#import "SSKeychain.h"

#import "AESCrypt.h"

static const NSTimeInterval kGuardAvaibleTimeDefault = 3 * 60; // 默认3分钟

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

- (BOOL)checkCode:(NSString *)code {
    if (!code) {
        return NO;
    }
    
    NSString *encryptedSeed = [SSKeychain passwordForService:CBWKeychainSeedService account:CBWKeychainAccountDefault];
    
    if (encryptedSeed.length > 0) {
        NSString *decryptedSeed = [AESCrypt decrypt:encryptedSeed password:code];
        if (decryptedSeed) {// success
            return YES;
        }
    }
    return NO;
}

- (BOOL)checkInWithCode:(NSString *)code {
    if ([self checkCode:code]) {// success
        NSLog(@"welcome");
        // cache code
        _code = code;
        // add timer into run loop
        [self p_addTimer];
        // notification
        [[NSNotificationCenter defaultCenter] postNotificationName:CBWNotificationCheckedIn object:nil];
        // return
        return YES;
    }
    
    return NO;
}

- (void)checkOut {
    _code = @"";
    [self p_invalidateTimer];
//    [self.timer invalidate];
    // notification
    [[NSNotificationCenter defaultCenter] postNotificationName:CBWNotificationCheckedOut object:nil];
//    _timer = nil;
}

- (void)signOut {
    if ([CBWDatabaseManager deleteAllDatas]) {
        
        [SSKeychain deletePasswordForService:CBWKeychainSeedService account:CBWKeychainAccountDefault];
        [SSKeychain deletePasswordForService:CBWKeychainHintService account:CBWKeychainAccountDefault];
        [SSKeychain deletePasswordForService:CBWKeychainMasterPasswordService account:CBWKeychainAccountDefault];
        [SSKeychain deletePasswordForService:CBWKeychainAccountDefault account:CBWKeychainAccountDefault];
        
        [CBWBackup deleteCloudKitRecord];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CBWNotificationSignedOut object:nil];
        
        [self checkOut];
    }
}

- (void)refreshTimer {
    if ([self.timer isValid]) {
        [self p_invalidateTimer];
        [self p_addTimer];
    }
}

- (BOOL)changeCode:(NSString *)code toNewCode:(NSString *)aNewCode {
    NSString *encryptedSeed = [SSKeychain passwordForService:CBWKeychainSeedService account:CBWKeychainAccountDefault];
    
    if (encryptedSeed.length > 0) {
        NSString *decryptedSeed = [AESCrypt decrypt:encryptedSeed password:code];
        if (decryptedSeed) {// success
            encryptedSeed = [AESCrypt encrypt:decryptedSeed password:aNewCode];
            if (encryptedSeed) {
                [SSKeychain setPassword:encryptedSeed forService:CBWKeychainSeedService account:CBWKeychainAccountDefault];
                return YES;
            }
        }
    }
    return NO;
}

- (void)p_invalidateTimer {
    [self.timer invalidate];
    _timer = nil;
}

- (void)p_addTimer {
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

@end
