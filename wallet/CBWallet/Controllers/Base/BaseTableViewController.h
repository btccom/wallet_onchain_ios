//
//  BaseTableViewController.h
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

// TODO: progress hud

#import <UIKit/UIKit.h>
#import "UIViewController+AlertMessage.h"
#import "UIViewController+AcitivityMonitor.h"
#import "UIViewController+RevealEnabled.h"

#import "DefaultSectionHeaderView.h"
#import "DefaultSectionFooterView.h"
#import "DefaultTableViewCell.h"
#import "FormControlActionButtonCell.h"
#import "FormControlBlockButtonCell.h"

extern NSString * _Nonnull const BaseTableViewSectionHeaderIdentifier;
extern NSString * _Nonnull const BaseTableViewSectionFooterIdentifier;
extern NSString * _Nonnull const BaseTableViewCellDefaultIdentifier;
extern NSString * _Nonnull const BaseTableViewCellActionButtonIdentifier;
extern NSString * _Nonnull const BaseTableViewCellBlockButtonIdentifier;

@interface BaseTableViewController : UITableViewController

- (void)dismiss:(nullable id)sender;

@end
