//
//  BaseListViewController.m
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"

NSString *const BaseListViewSectionHeaderIdentifier = @"list.section.header";
NSString *const BaseListViewCellTransactionIdentifier = @"list.cell.transaction";
NSString *const BaseListViewCellAddressIdentifier = @"list.cell.address";

@interface BaseListViewController ()

@end

@implementation BaseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[ListSectionHeaderView class] forHeaderFooterViewReuseIdentifier:BaseListViewSectionHeaderIdentifier];
    [self.tableView registerClass:[TransactionCell class] forCellReuseIdentifier:BaseListViewCellTransactionIdentifier];
    [self.tableView registerClass:[AddressCell class] forCellReuseIdentifier:BaseListViewCellAddressIdentifier];
}

#pragma mark - Public Method
- (void)requestDidStart {
    self.requesting = YES;
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
- (void)requestDidStop {
    self.requesting = NO;
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - <UITableViewDataSource>

#pragma mark - <UITableViewDelegate>
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:BaseListViewSectionHeaderIdentifier];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView titleForHeaderInSection:section].length > 0) {
        return CBWListSectionHeaderHeight;
    }
    return 0;// auto
}

@end
