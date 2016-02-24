//
//  ProfileViewController.h
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProfileViewController, Wallet;

@protocol ProfileViewControllerDelegate <NSObject>

@optional
- (void)profileViewController:(ProfileViewController *)viewController didSelectWallet:(Wallet *)wallet;

@end

/// Switch wallet, manage recipient contacts, settings
@interface ProfileViewController : UITableViewController

@end
