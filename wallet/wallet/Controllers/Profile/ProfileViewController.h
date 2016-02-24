//
//  ProfileViewController.h
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProfileViewController, BTCAccount;

@protocol ProfileViewControllerDelegate <NSObject>

@optional
- (void)profileViewController:(ProfileViewController *)viewController didSelectAccount:(BTCAccount *)account;

@end

/// Switch wallet, manage recipient contacts, settings
@interface ProfileViewController : UITableViewController

@end
