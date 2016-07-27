//
//  TransactionListViewController.m
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "TransactionListViewController.h"

@interface TransactionListViewController ()

@end

@implementation TransactionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.account) {
        self.title = NSLocalizedStringFromTable(@"Navigation all_transactions", @"CBW", @"All Transactions");
    } else {
        self.title = NSLocalizedStringFromTable(@"Navigation transaction_list", @"CBW", @"Transaction List");
    }
}

@end
