//
//  SignInViewController.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/5/31.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SignInViewController;

@protocol SignInViewControllerDelegate <NSObject>

- (void)signInViewControllerDidUnlock:(SignInViewController *)vc;

@end

/// input master passwordk or use touch id to sign in the wallet
@interface SignInViewController : UIViewController

@property (nonatomic, weak) id<SignInViewControllerDelegate> delegate;

- (void)showKeyboard;

@end
