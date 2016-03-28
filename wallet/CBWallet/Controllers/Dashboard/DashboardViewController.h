//
//  DashboardViewController.h
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BaseListViewController.h"

/// 首页
/// - Profile
/// - Address List
/// - Scan
/// - Send
/// - Receive
/// - Recent Transactions
@interface DashboardViewController : BaseListViewController

- (void)reload;
- (void)reloadTransactions;

@end

