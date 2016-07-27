//
//  UIViewController+AcitivityMonitor.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/5/12.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const ActivityMonitorActViewDidAppear;

@interface UIViewController (AcitivityMonitor)

- (void)reportActivity:(NSString *)activity;

@end
