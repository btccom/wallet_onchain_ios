//
//  ProfileViewController.h
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"

@class ProfileViewController, Account;

@protocol ProfileViewControllerDelegate <NSObject>

@optional
- (void)profileViewController:(nonnull ProfileViewController *)viewController didSelectAccount:(nonnull Account *)account;

@end

/// Switch wallet, manage recipient contacts, settings
@interface ProfileViewController : BaseListViewController

@property (nonatomic, weak) id<ProfileViewControllerDelegate> delegate;

@end
