//
//  AddressViewController.h
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"
@class Address;

typedef NS_ENUM(NSUInteger, AddressActionType) {
    /// default, show summary
    AddressActionTypeDefault = 0,
    /// Receive, just label + address
    AddressActionTypeReceive
};

/// 地址视图
/// - 二维码
/// - 地址
/// - 标签
@interface AddressViewController : BaseListViewController

@property (nonatomic, assign, readonly) AddressActionType actionType;
@property (nonatomic, strong, readonly) Address * _Nonnull address;

- (nonnull instancetype)initWithAddress:(nonnull Address *)address actionType:(AddressActionType)actionType;

@end
