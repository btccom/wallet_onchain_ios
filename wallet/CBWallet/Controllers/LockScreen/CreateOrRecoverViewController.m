//
//  CreateOrRecoverViewController.m
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CreateOrRecoverViewController.h"
#import "LockScreenController.h"
#import "MasterPasswordViewController.h"
#import "RecoverViewController.h"

#import "PrimaryButton.h"

@interface CreateOrRecoverViewController ()

@end

@implementation CreateOrRecoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedStringFromTable(@"Navigation CreateOrRecover", @"CBW", @"Welcome");
    self.view.backgroundColor = [UIColor CBWWhiteColor];
    
    CGFloat stageWidth = CGRectGetWidth(self.view.frame);
    CGFloat stageHeight = CGRectGetHeight(self.view.frame);
    PrimaryButton *createButton = [[PrimaryButton alloc] initWithFrame:CGRectMake(20.f, stageHeight * 0.6f, stageWidth - 40.f, CBWCellHeightDefault)];
    [createButton addTarget:self action:@selector(p_handleCreate:) forControlEvents:UIControlEventTouchUpInside];
    [createButton setTitle:NSLocalizedStringFromTable(@"Button Create Wallet", @"CBW", "Create Wallet") forState:UIControlStateNormal];
    [self.view addSubview:createButton];
    PrimaryButton *recoverButton = [[PrimaryButton alloc] initWithFrame:CGRectOffset(createButton.frame, 0, CBWCellHeightDefault + 16.f)];
    [recoverButton addTarget:self action:@selector(p_handleRecover:) forControlEvents:UIControlEventTouchUpInside];
    [recoverButton setTitle:NSLocalizedStringFromTable(@"Button Recover Wallet", @"CBW", "Recover Wallet") forState:UIControlStateNormal];
    [self.view addSubview:recoverButton];
}

#pragma mark - Private Method
- (void)p_handleCreate:(id)sender {
    MasterPasswordViewController *masterPasswordViewController = [[MasterPasswordViewController alloc] init];
    masterPasswordViewController.actionType = LockScreenActionTypeSignUp;
    [self.navigationController pushViewController:masterPasswordViewController animated:YES];
}
- (void)p_handleRecover:(id)sender {
    RecoverViewController *recoverViewController = [[RecoverViewController alloc] init];
    [self.navigationController pushViewController:recoverViewController animated:YES];
}

@end
