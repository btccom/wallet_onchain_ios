//
//  CameraViewController.m
//  wallet
//
//  Created by Zin on 16/2/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CameraViewController.h"

@implementation CameraViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_close"] style:UIBarButtonItemStylePlain target:self action:@selector(p_dismiss:)];
}

#pragma mark - Private Method
- (void)p_dismiss:(id)sender {
    if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
