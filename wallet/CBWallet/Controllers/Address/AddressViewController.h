//
//  AddressViewController.h
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"
@class CBWAddress;

/// 地址视图
/// - 二维码
/// - 地址
/// - 标签
@interface AddressViewController : BaseListViewController

@property (nonatomic, assign) AddressActionType actionType;
@property (nonatomic, strong, readonly) CBWAddress * _Nonnull address;

- (nonnull instancetype)initWithAddress:(nonnull CBWAddress *)address actionType:(AddressActionType)actionType;

- (void)reload;

@end
