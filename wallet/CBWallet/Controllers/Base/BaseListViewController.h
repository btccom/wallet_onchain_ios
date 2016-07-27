//
//  BaseListViewController.h
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseTableViewController.h"
#import "DefaultSectionHeaderView.h"
#import "TransactionCell.h"
#import "AddressCell.h"

extern NSString * _Nonnull const BaseListViewCellTransactionIdentifier;
extern NSString * _Nonnull const BaseListViewCellAddressIdentifier;

@interface BaseListViewController : BaseTableViewController

@property (nonatomic, assign, getter=isRequesting) BOOL requesting;

- (void)requestDidStart;
- (void)requestDidStop;

@end
