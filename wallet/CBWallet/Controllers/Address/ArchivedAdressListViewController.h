//
//  ArchivedAdressListViewController.h
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"
#import "AddressViewController.h"

@class Account;

@interface ArchivedAdressListViewController : BaseListViewController

@property (nonatomic, assign) AddressActionType actionType;
/// 显示该账户地址
@property (nonatomic, strong, nullable) Account *account;

- (nonnull instancetype)initWithAccount:(nonnull Account *)account;

@end
