//
//  TransactionViewController.h
//  wallet
//
//  Created by Zin on 16/2/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"

@class Transaction;

@interface TransactionViewController : BaseListViewController

@property (nonatomic, strong, nullable) Transaction *transaction;

- (instancetype _Nonnull)initWithTransaction:(Transaction * _Nonnull)transaction;

@end
