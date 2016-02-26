//
//  ImagePickerController.m
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "ImagePickerController.h"
#import "CameraViewController.h"

@interface ImagePickerController ()

@end

@implementation ImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor BTCCBackgroundColor];
    [self setViewControllers:@[[[CameraViewController alloc] init]]];
}

@end
