//
//  BaseViewController.m
//  wallet
//
//  Created by Zin on 16/2/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    [self.navigationController.navigationBar setTintColor:[UIColor BTCCPrimaryColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor BTCCBlackColor]}];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bar_tint_white"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.view.backgroundColor = [UIColor BTCCBackgroundColor];
    
    self.view.backgroundColor = [UIColor BTCCBackgroundColor];
}

@end
