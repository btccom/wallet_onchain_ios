//
//  AddressListViewController.h
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"
#import "AddressViewController.h"

@class Account;

@interface AddressListViewController : BaseListViewController

@property (nonatomic, assign) AddressActionType actionType;

/// 显示该账户地址
@property (nonatomic, strong) Account * _Nullable account;

@end
