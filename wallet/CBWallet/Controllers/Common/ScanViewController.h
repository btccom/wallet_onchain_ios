//
//  ScanViewController.h
//  wallet
//
//  Created by Zin on 16/2/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseViewController.h"

@class ScanViewController;

@protocol ScanViewControllerDelegate <NSObject>

- (void)scanViewController:(ScanViewController *)viewController didScanString:(NSString *)string;

@optional
- (BOOL)scanViewControllerWillDismiss:(ScanViewController *)viewController;

@end

@interface ScanViewController : BaseViewController

@property (nonatomic, weak) id<ScanViewControllerDelegate> delegate;

@end
