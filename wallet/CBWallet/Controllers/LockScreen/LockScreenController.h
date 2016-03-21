//
//  LockScreenViewController.h
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterPasswordViewController.h"
#import "InitialWalletSettingViewController.h"

@class LockScreenController;

@protocol LockScreenControllerDelegate <NSObject, UINavigationControllerDelegate>

- (void)lockScreenController:(LockScreenController * _Nonnull)controller didUnlockWithActionType:(LockScreenActionType)type;

@end

/// Container, 启动后的登录页
@interface LockScreenController : UINavigationController<MasterPasswordViewControllerDelegate, InitialWalletSettingViewControllerDelegate>

@property (nonatomic, assign) LockScreenActionType actionType;
@property (nonatomic, weak, nullable) id<LockScreenControllerDelegate> delegate;

@end
