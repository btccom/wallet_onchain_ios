//
//  AccountStore.h
//  CBWallet
//
//  Created by Zin on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "RecordObjectStore.h"
#import "Account.h"

extern NSString *const _Nonnull AccountStoreWatchedAccountLabel;

@interface AccountStore : RecordObjectStore

- (nonnull Account *)customDefaultAccount;

/// get watched only account
- (nonnull Account *)watchedAccount;

@end
