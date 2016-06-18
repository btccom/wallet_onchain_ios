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
//    [self.refreshControl beginRefreshing];
    DLog(@"request did start");
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
- (void)requestDidStop {
    self.requesting = NO;
    [self.refreshControl endRefreshing];
    DLog(@"request did stop");
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - <UITableViewDataSource>

#pragma mark - <UITableViewDelegate>

@end
