//
//  AddressListViewController.h
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"
#import "AddressViewController.h"

@class Account, AddressListViewController;

@protocol AddressListViewControllerDelegate <NSObject>

@optional
- (void)addressListViewController:(nonnull AddressListViewController *)controller didSelectAddress:(nonnull Address *)address;
- (void)addressListViewController:(nonnull AddressListViewController *)controller didDeselectAddress:(nonnull Address *)address;

@end

@interface AddressListViewController : BaseListViewController

@property (nonatomic, assign) AddressActionType actionType;
@property (nonatomic, strong, nullable) NSMutableArray *selectedAddress;

/// 显示该账户地址
@property (nonatomic, strong, nullable) Account *account;

@property (nonatomic, weak, nullable) id<AddressListViewControllerDelegate> delegate;

- (nonnull instancetype)initWithAccount:(nonnull Account *)account;

- (void)reload;

@end
