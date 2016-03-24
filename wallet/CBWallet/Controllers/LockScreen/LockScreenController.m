//
//  LockScreenViewController.m
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "LockScreenController.h"
#import "CreateOrRecoverViewController.h"
#import "MasterPasswordViewController.h"

@interface LockScreenController ()

@end

@implementation LockScreenController
@dynamic delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    switch (self.actionType) {
        case LockScreenActionTypeSignUp: {
            CreateOrRecoverViewController *corViewController = [[CreateOrRecoverViewController alloc] init];
            [self setViewControllers:@[corViewController]];
            break;
        }
        case LockScreenActionTypeSignIn: {
            MasterPasswordViewController *masterPasswordViewController = [[MasterPasswordViewController alloc] init];
            masterPasswordViewController.actionType = self.actionType;
            masterPasswordViewController.delegate = self;
            [self setViewControllers:@[masterPasswordViewController]];
            break;
        }
    }
    
    self.view.backgroundColor = [UIColor CBWBackgroundColor];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"bar_tint_white"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[UIImage new]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Method

#pragma mark - Private Method

#pragma mark <MasterPasswordViewControllerDelegate>
- (void)masterPasswordViewController:(MasterPasswordViewController *)controller didInputPassword:(NSString *)password {
    // TODO: check master password
    
    // call delegate to unlock
    [self.delegate lockScreenController:self didUnlockWithActionType:self.actionType];
}

#pragma mark <InitialWalletSettingViewControllerDelegate>
- (void)initialWalletSettingViewControllerDidComplete:(InitialWalletSettingViewController *)controller {
    // call delegate to unlock
    [self.delegate lockScreenController:self didUnlockWithActionType:self.actionType];
}

@end
