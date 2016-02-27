//
//  AddressListViewController.h
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"

@class Account;

typedef NS_ENUM(NSUInteger, AddressListActionType) {
    /// default, show summary
    AddressListActionTypeList = 0,
    /// Receive, just label + address
    AddressListActionTypeReceive
};

@interface AddressListViewController : BaseListViewController

@property (nonatomic, assign) AddressListActionType actionType;

/// 显示该账户地址
@property (nonatomic, strong) Account * _Nullable account;

@end
