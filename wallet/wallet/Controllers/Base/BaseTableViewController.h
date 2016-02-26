//
//  BaseTableViewController.h
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionCell.h"

extern NSString * _Nonnull const BaseTableViewCellTransactionIdentifier;

@interface BaseTableViewController : UITableViewController

- (void)dismiss:(id _Nullable)sender;

@end
