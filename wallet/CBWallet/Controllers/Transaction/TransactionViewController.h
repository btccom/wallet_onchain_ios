//
//  TransactionViewController.h
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"

@class CBWTransaction;

@interface TransactionViewController : BaseListViewController

@property (nonatomic, strong, nullable) CBWTransaction *transaction;
@property (nonatomic, copy, nullable) NSString *hashId;

- (nonnull instancetype)initWithTransaction:(nonnull CBWTransaction *)transaction;
- (nonnull instancetype)initWithTransactionHashId:(nonnull NSString *)hashId;

@end
