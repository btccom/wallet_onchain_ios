//
//  BlankViewController.m
//  CBWallet
//
//  Created by Zin on 16/7/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BlankViewController.h"

@interface BlankViewController ()

@end

@implementation BlankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"background"];
    imageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imageView];
}

@end
