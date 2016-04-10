//
//  AccountStore.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRecordObjectStore.h"
#import "CBWAccount.h"

extern NSString *const _Nonnull AccountStoreWatchedAccountLabel;

@interface CBWAccountStore : CBWRecordObjectStore

- (nonnull CBWAccount *)customDefaultAccount;

/// get watched only account
- (nonnull CBWAccount *)watchedAccount;

@end
