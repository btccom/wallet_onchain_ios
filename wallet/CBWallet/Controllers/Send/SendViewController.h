//
//  SendViewController.h
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseFormViewController.h"

typedef NS_ENUM(NSInteger, SendViewControllerMode) {
    SendViewControllerModeQuickly = 0,
    SendViewControllerModeAdvanced
};

/// 发款
@interface SendViewController : BaseFormViewController

@property (nonatomic, assign) SendViewControllerMode mode;

@end
