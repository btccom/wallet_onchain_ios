//
//  Account.h
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "RecordObject.h"

@class AccountStore;

/// <code><b>BIP32</b> m/idx</code>, <code>idx</code> to specify account as wallet
///
/// <code>idx < 0</code> means watched account
@interface Account : RecordObject

/// idx < 0 means watched account
@property (nonatomic, assign) NSInteger idx;
@property (nonatomic, copy, nullable) NSString *label;
@property (nonatomic, assign, getter=isCustomDefaultEnabled) BOOL customDefaultEnabled;

/// create account, import account.
+ (nonnull instancetype)newAccountWithIdx:(NSInteger)idx label:(nullable NSString *)label inStore:(nonnull AccountStore *)store;

@end
