//
//  SignInMasterPasswordViewController.m
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "MasterPasswordViewController.h"

@interface MasterPasswordViewController ()

@end

@implementation MasterPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedStringFromTable(@"Navigation MasterPassword", @"BTCC", @"Master Password");
    
    UIButton *button = [[UIButton alloc] initWithFrame:self.view.bounds];
    [button setTitle:NSLocalizedStringFromTable(@"Button MasterPassword", @"BTCC", @"Master Password") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(handleButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}


#pragma mark - Private Method

/// test
- (void)handleButton:(id)sender {
    [self.delegate masterPasswordViewController:self didInputPassword:@"master password"];
}

@end
