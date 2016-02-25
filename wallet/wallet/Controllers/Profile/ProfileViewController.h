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
- (void)profileViewController:(ProfileViewController *)viewController didSelectAccount:(Account *)account;

@end

/// Switch wallet, manage recipient contacts, settings
@interface ProfileViewController : BaseListViewController

@end
