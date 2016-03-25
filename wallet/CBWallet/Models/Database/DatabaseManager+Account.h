//
//  DatabaseManager+Account.h
//  CBWallet
//
//  Created by Zin on 16/3/21.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "DatabaseManager.h"

@class Account, AccountStore;

@interface DatabaseManager (Account)

- (void)fetchAccountsToStore:(AccountStore *)store;
- (void)saveAccount:(Account *)account;

@end
