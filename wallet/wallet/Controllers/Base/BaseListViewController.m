//
//  BaseListViewController.m
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"

NSString *const BaseListViewSectionHeaderIdentifier = @"list.section.header";

@interface BaseListViewController ()

@end

@implementation BaseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[ListSectionHeaderView class] forHeaderFooterViewReuseIdentifier:BaseListViewSectionHeaderIdentifier];
}

#pragma mark - UITableViewDataSource

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:BaseListViewSectionHeaderIdentifier];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return BTCCListSectionHeaderHeight;
}

@end
