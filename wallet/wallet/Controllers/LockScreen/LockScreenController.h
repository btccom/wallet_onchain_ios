//
//  LockScreenViewController.h
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LockScreenActionType) {
    /// 注册，初始化钱包，create or recover
    LockScreenActionTypeSignUp,
    /// 登录，如应用被唤醒时，master password
    LockScreenActionTypeSignIn
};

@class LockScreenController;

@protocol LockScreenControllerDelegate <NSObject, UINavigationControllerDelegate>

- (void)lockScreenController:(LockScreenController * _Nonnull)controller didUnlockWithActionType:(LockScreenActionType)type;

@end

/// Container, 启动后的登录页
@interface LockScreenController : UINavigationController

@property (nonatomic, assign) LockScreenActionType actionType;
@property (nonatomic, weak, nullable) id<LockScreenControllerDelegate> delegate;

@end
