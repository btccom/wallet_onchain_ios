//
//  BaseListViewController.h
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseTableViewController.h"
#import "ListSectionHeaderView.h"
#import "TransactionCell.h"
#import "AddressCell.h"

extern NSString * _Nonnull const BaseListViewSectionHeaderIdentifier;
extern NSString * _Nonnull const BaseListViewCellTransactionIdentifier;
extern NSString * _Nonnull const BaseListViewCellAddressIdentifier;

@interface BaseListViewController : BaseTableViewController

@end
