//
//  AddressListViewController.h
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"
#import "AddressViewController.h"

@class CBWAccount, AddressListViewController;

@protocol AddressListViewControllerDelegate <NSObject>

@optional
- (void)addressListViewController:(nonnull AddressListViewController *)controller didSelectAddress:(nullable CBWAddress *)address;
- (void)addressListViewController:(nonnull AddressListViewController *)controller didDeselectAddress:(nullable CBWAddress *)address;
- (void)addressListViewControllerDidUpdate:(nonnull AddressListViewController *)controller;

@end

@interface AddressListViewController : BaseListViewController

@property (nonatomic, assign) AddressActionType actionType;
@property (nonatomic, strong, nullable) NSMutableArray *selectedAddress;

/// 显示该账户地址
@property (nonatomic, strong, nullable) CBWAccount *account;

@property (nonatomic, weak, nullable) id<AddressListViewControllerDelegate> delegate;

- (nonnull instancetype)initWithAccount:(nonnull CBWAccount *)account;

- (void)reload;

@end
