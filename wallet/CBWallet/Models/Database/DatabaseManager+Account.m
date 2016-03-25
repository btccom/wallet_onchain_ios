//
//  DatabaseManager+Account.m
//  CBWallet
//
//  Created by Zin on 16/3/21.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "DatabaseManager+Account.h"
#import "Account.h"

static NSString *const kDatabaseManagerTableAccount = @"account";

@implementation DatabaseManager (Account)

- (NSArray *)fetchAccounts {
    return nil;
}

- (void)saveAccount:(Account *)account {
    if ([self.db open]) {
//        if (account.rid < 0) {
//            // 新记录
//            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@", kDatabaseManagerTableAccount];
//            [self.db executeUpdate:sql];
//        }
        [self.db close];
    }
}

- (void)deleteAccount:(Account *)account {
    DLog(@"to delete account: %@", account);
}

@end
