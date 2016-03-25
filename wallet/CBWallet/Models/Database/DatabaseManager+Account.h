//
//  DatabaseManager+Account.h
//  CBWallet
//
//  Created by Zin on 16/3/21.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "DatabaseManager.h"

@class Account;

@interface DatabaseManager (Account)

- (NSArray *)fetchAccounts;
- (void)saveAccount:(Account *)account;
- (void)deleteAccount:(Account *)account;

@end
