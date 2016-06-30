//
//  AddressExplorerViewController.h
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"
@class CBWAddress;

typedef NS_ENUM(NSUInteger, AddressExplorerType) {
    AddressExplorerTypeReceive,
    /// explore a address not stored, no label, show summary
    AddressExplorerTypeExternal
};

/// 地址视图
/// - 二维码
/// - 地址
/// - 标签
@interface AddressExplorerViewController : BaseListViewController

@property (nonatomic, assign) AddressExplorerType explorerType;
@property (nonatomic, strong, readonly) CBWAddress * _Nonnull address;

- (nonnull instancetype)initWithAddress:(nonnull CBWAddress *)address explorerType:(AddressExplorerType)explorerType;

@end
