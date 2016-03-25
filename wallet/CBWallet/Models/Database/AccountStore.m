//
//  AccountStore.m
//  CBWallet
//
//  Created by Zin on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AccountStore.h"
#import "DatabaseManager.h"

@implementation AccountStore

- (Account *)customDefaultAccount {
    __block Account *account = (Account *)[records firstObject];
    [records enumerateObjectsUsingBlock:^(RecordObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (((Account *)obj).isCustomDefaultEnabled) {
            account = (Account *)obj;
            *stop = YES;
        }
    }];
    return account;
}

@end
