//
//  UIViewController+RevealEnabled.m
//  CBWallet
//
//  Created by Zin on 16/7/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "UIViewController+RevealEnabled.h"
#import "SWRevealViewController.h"

@implementation UIViewController (RevealEnabled)

- (void)enableRevealInteraction {
    // reveal view controller
    SWRevealViewController *revealViewController = [self revealViewController];
    [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:revealViewController.tapGestureRecognizer];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"navigation_drawer"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:revealViewController action:@selector(revealToggle:)];
}

@end
