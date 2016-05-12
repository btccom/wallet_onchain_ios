//
//  UIViewController+AcitivityMonitor.m
//  CBWallet
//
//  Created by Zin on 16/5/12.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "UIViewController+AcitivityMonitor.h"
#import "Guard.h"

NSString *const ActivityMonitorActViewDidAppear = @"viewDidAppear";

@implementation UIViewController (AcitivityMonitor)

- (void)reportActivity:(NSString *)activity {
    [[Guard globalGuard] refreshTimer];
}

@end
