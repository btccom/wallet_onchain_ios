//
//  AddressViewController.h
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"
@class CBWAddress;

typedef NS_ENUM(NSUInteger, AddressActionType) {
    /// default, show summary
    AddressActionTypeDefault = 0,
    /// send, won't jump to address view from list
    AddressActionTypeSend,
    /// receive change, won't jump to address view from list
    AddressActionTypeChange,
    /// receive, just label + address
    AddressActionTypeReceive,
    /// explore a address not stored, no label, show summary
    AddressActionTypeExplore,
    /// preview to create
    AddressActionTypeCreate
};

/// 地址视图
/// - 二维码
/// - 地址
/// - 标签
@interface AddressViewController : BaseListViewController

@property (nonatomic, assign) AddressActionType actionType;
@property (nonatomic, strong, readonly) CBWAddress * _Nonnull address;

- (nonnull instancetype)initWithAddress:(nonnull CBWAddress *)address actionType:(AddressActionType)actionType;

@end
