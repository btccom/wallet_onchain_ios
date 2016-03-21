//
//  SignInSettingViewController.h
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InitialWalletSettingViewController;

@protocol InitialWalletSettingViewControllerDelegate <NSObject>

- (void)initialWalletSettingViewControllerDidComplete:(InitialWalletSettingViewController * _Nonnull)controller;

@end

/// 设置，是否开启 touchid 及 iCloud 自动备份
@interface InitialWalletSettingViewController : UIViewController

@property (nonatomic, weak, nullable) id<InitialWalletSettingViewControllerDelegate> delegate;

@end
