//
//  BaseTableViewController.h
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DefaultCell.h"
#import "ActionCell.h"

extern NSString * _Nonnull const BaseTableViewCellDefaultIdentifier;
extern NSString * _Nonnull const BaseTableViewCellActionIdentifier;

@interface BaseTableViewController : UITableViewController

- (void)dismiss:(nullable id)sender;

@end
