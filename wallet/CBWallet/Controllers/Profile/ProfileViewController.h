//
//  ProfileViewController.h
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"

@class ProfileViewController, Account, AccountStore;

@protocol ProfileViewControllerDelegate <NSObject>

@optional
- (void)profileViewController:(nonnull ProfileViewController *)viewController didSelectAccount:(nonnull Account *)account;

@end

/// Switch wallet, manage recipient contacts, settings
@interface ProfileViewController : BaseListViewController

@property (nonatomic, strong, nonnull) AccountStore *accountStore;
@property (nonatomic, weak, nullable) id<ProfileViewControllerDelegate> delegate;

- (nonnull instancetype)initWithAccountStore:(nonnull AccountStore *)store;

@end
