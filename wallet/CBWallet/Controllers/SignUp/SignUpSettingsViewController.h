//
//  SignUpSettingsViewController.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/5/31.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SignUpSettingsViewController;

@protocol SignUpSettingsViewControllerDelegate <NSObject>

- (void)signUpSettingsViewControllerDidComplete:(SignUpSettingsViewController *)vc;

@end

/// set iCloud, touch ID
@interface SignUpSettingsViewController : UIViewController

@property (nonatomic, weak) id<SignUpSettingsViewControllerDelegate> delegate;

@end
