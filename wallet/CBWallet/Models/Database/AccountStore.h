//
//  AccountStore.h
//  CBWallet
//
//  Created by Zin on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "RecordObjectStore.h"
#import "Account.h"

@interface AccountStore : RecordObjectStore

- (nonnull Account *)customDefaultAccount;

@end
