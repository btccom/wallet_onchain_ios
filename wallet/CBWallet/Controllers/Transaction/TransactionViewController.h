//
//  TransactionViewController.h
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"

@class Transaction;

@interface TransactionViewController : BaseListViewController

@property (nonatomic, strong, nullable) Transaction *transaction;
@property (nonatomic, copy, nullable) NSString *hashId;

- (nonnull instancetype)initWithTransaction:(nonnull Transaction *)transaction;
- (nonnull instancetype)initWithTransactionHashId:(nonnull NSString *)hashId;

@end
