//
//  BaseListViewController.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//
// TODO: 下拉刷新需要刷新锁屏等待时间

#import "BaseListViewController.h"

NSString *const BaseListViewCellTransactionIdentifier = @"list.cell.transaction";
NSString *const BaseListViewCellAddressIdentifier = @"list.cell.address";

@interface BaseListViewController ()

@end

@implementation BaseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[TransactionCell class] forCellReuseIdentifier:BaseListViewCellTransactionIdentifier];
    [self.tableView registerClass:[AddressCell class] forCellReuseIdentifier:BaseListViewCellAddressIdentifier];
}

#pragma mark - Public Method
- (void)requestDidStart {
    self.requesting = YES;
    
    if (!self.tableView.tableFooterView) {
        UIActivityIndicatorView *fetchingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.tableView.tableFooterView = fetchingIndicatorView;
        [fetchingIndicatorView startAnimating];
    }
}
- (void)requestDidStop {
    self.requesting = NO;
    [self.refreshControl endRefreshing];
    
    if ([self.tableView.tableFooterView isKindOfClass:[UIActivityIndicatorView class]]) {
        [((UIActivityIndicatorView *)self.tableView.tableFooterView) stopAnimating];
        self.tableView.tableFooterView = nil;
    }
}

#pragma mark - <UITableViewDataSource>

#pragma mark - <UITableViewDelegate>

@end
