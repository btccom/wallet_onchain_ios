//
//  SignInSettingViewController.m
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "InitialWalletSettingViewController.h"

#import "PrimaryButton.h"

@interface InitialWalletSettingViewController ()

@end

@implementation InitialWalletSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor CBWWhiteColor];
    self.title = NSLocalizedStringFromTable(@"Navigation Initial Wallet Setting", @"CBW", @"Initial Wallet Setting");
    
    CGFloat stageWidth = CGRectGetWidth(self.view.frame);
    CGFloat stageHeight = CGRectGetHeight(self.view.frame);
    PrimaryButton *button = [[PrimaryButton alloc] initWithFrame:CGRectMake(20.f, stageHeight * 0.6f, stageWidth - 40.f, CBWCellHeightDefault)];
    [button setTitle:NSLocalizedStringFromTable(@"Button Complete", @"CBW", @"Complete Initial Settings") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(p_handleCreate:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
- (void)p_handleCreate:(id)sender {
    [self.delegate initialWalletSettingViewControllerDidComplete:self];
}

@end
