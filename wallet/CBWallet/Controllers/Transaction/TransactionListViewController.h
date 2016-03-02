//
//  TransactionListViewController.h
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"

@class Account;

@interface TransactionListViewController : BaseListViewController

/// 查询交易的账户，如果不设置将显示全部账户的交易，可能需要更长的等待时间
@property (nonatomic, strong) Account * _Nullable account;

@end
