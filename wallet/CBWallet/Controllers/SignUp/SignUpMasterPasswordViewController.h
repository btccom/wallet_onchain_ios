//
//  SignUpMasterPasswordViewController.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/5/31.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SignUpMasterPasswordViewController;

@protocol SignUpMasterPasswordViewControllerDelegate <NSObject>

- (void)signUpMasterPasswordViewController:(SignUpMasterPasswordViewController *)vc didInputPassword:(NSString *)password andHint:(NSString *)hint;

@end

/// input master password and hint, send to delegate
@interface SignUpMasterPasswordViewController : UIViewController

@property (nonatomic, assign) BOOL recoverEnabled;
@property (nonatomic, copy) NSString *hint;

@property (nonatomic, weak) id<SignUpMasterPasswordViewControllerDelegate> delegate;

- (void)becomeFirstResponder;

@end
