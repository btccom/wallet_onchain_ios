//
//  SystemManager.m
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "SystemManager.h"
//#import "SSKeychain.h"
#import "Database.h"

@implementation SystemManager

+ (instancetype)defaultManager {
    static id staticInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        staticInstance = [[self alloc] init];
    });
    return staticInstance;
}

- (BOOL)isWalletInstalled {
//#warning clearing seed every launch for development.
//    [SSKeychain deletePasswordForService:CBWKeyChainSeedService account:CBWKeyChainAccountDefault];
    // FIXME: 检查数据库而不是 sskeychain
    
    return [CBWDatabaseManager checkAccountInstalled];
    
//    NSData *seed = [SSKeychain passwordDataForService:CBWKeyChainSeedService account:CBWKeyChainAccountDefault];
//    if (seed) {
//        return YES;
//    }
//    return NO;
}

- (BOOL)isiCloudAccountSignedIn {
    if ([NSFileManager defaultManager].ubiquityIdentityToken) {
        return YES;
    }
    return NO;
}

@end
