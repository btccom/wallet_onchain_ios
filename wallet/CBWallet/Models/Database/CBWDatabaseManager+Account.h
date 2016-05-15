//
//  DatabaseManager+Account.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/21.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWDatabaseManager.h"

@class CBWAccount, CBWAccountStore;

@interface CBWDatabaseManager (Account)

- (void)fetchAccountsToStore:(CBWAccountStore *)store;
- (void)saveAccount:(CBWAccount *)account;
- (BOOL)checkAccountLabel:(NSString *)label;
+ (BOOL)checkAccountInstalled;

@end
