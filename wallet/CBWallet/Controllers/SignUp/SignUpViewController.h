//
//  SignUpViewController.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/5/31.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SignUpViewController;

@protocol SignUpViewControllerDelegate <NSObject>

- (void)SignUpViewControllerDidComplete:(SignUpViewController *)vc;

@end

/// create or recover a wallet
@interface SignUpViewController : UIViewController

@property (nonatomic, weak) id<SignUpViewControllerDelegate> delegate;

@end
