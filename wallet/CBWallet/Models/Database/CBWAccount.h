//
//  Account.h
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRecordObject.h"

@class CBWAccountStore;

/// <code><b>BIP32</b> m/idx</code>, <code>idx</code> to specify account as wallet
///
/// <code>idx < 0</code> means watched account
@interface CBWAccount : CBWRecordObject

/// idx < 0 means watched account
@property (nonatomic, assign) NSInteger idx;
@property (nonatomic, copy, nullable) NSString *label;
@property (nonatomic, assign, getter=isCustomDefaultEnabled) BOOL customDefaultEnabled;

/// create account, import account.
+ (nonnull instancetype)newAccountWithIdx:(NSInteger)idx label:(nullable NSString *)label inStore:(nonnull CBWAccountStore *)store;

+ (BOOL)checkLabel:(nonnull NSString *)label;

@end
