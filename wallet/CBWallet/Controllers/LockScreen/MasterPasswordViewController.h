//
//  SignInMasterPasswordViewController.h
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MasterPasswordViewController;

@protocol MasterPasswordViewControllerDelegate <NSObject>

- (void)masterPasswordViewController:(MasterPasswordViewController * _Nonnull)controller didInputPassword:(NSString * _Nonnull)password;

@end

/// 创建：设置主密码，之后生成第一个根私钥，创建账号成功
///
/// 恢复：使用主密码，从备份文件中恢复根私钥及使用数据，恢复账号成功
///
/// 启动: 输入主密码或指纹登录
@interface MasterPasswordViewController : UIViewController

@property (nonatomic, weak, nullable) id<MasterPasswordViewControllerDelegate> delegate;

@end
