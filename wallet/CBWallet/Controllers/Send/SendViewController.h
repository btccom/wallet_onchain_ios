//
//  SendViewController.h
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseFormViewController.h"

@class Account;

typedef NS_ENUM(NSInteger, SendViewControllerMode) {
    SendViewControllerModeQuickly = 0,
    SendViewControllerModeAdvanced
};

/// 发款
@interface SendViewController : BaseFormViewController

@property (nonatomic, assign) SendViewControllerMode mode;
@property (nonatomic, strong) Account *account;

- (instancetype)initWithAccount:(Account *)account;

@end
