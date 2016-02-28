//
//  DashboardViewController.m
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "DashboardViewController.h"
#import "ProfileViewController.h"
#import "AddressListViewController.h"// explorer or receive
#import "ImagePickerController.h"// scan to explorer or send
#import "TransactionListViewController.h"// list all transactions
#import "TransactionViewController.h" // transaction detail
#import "SendViewController.h"// send

#import "DashboardHeaderView.h"

#import "Transaction.h"

@interface DashboardViewController ()
@property (nonatomic, strong) NSMutableArray *transactions; // of Transaction
@end

@implementation DashboardViewController

#pragma mark - Property
- (NSMutableArray *)transactions {
    if (!_transactions) {
        _transactions = [[NSMutableArray alloc] init];
    }
    return _transactions;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = NSLocalizedStringFromTable(@"Navigation Dashboard", @"BTCC", @"Dashboard");
    
    // set navigation buttons
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"navigation_drawer"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleProfile:)];
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_address"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleAddressList:)], [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"navigation_scan"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleScan:)]];
    
    // set table header
    CGFloat offsetHeight = -64.f;// status bar height + navigation bar height
    CGRect dashboardHeaderViewframe = self.view.bounds;
    dashboardHeaderViewframe.size.height = roundf(CGRectGetWidth(dashboardHeaderViewframe) / 16.f * 9.f) + offsetHeight;
    DashboardHeaderView *dashboardHeaderView = [[DashboardHeaderView alloc] initWithFrame:dashboardHeaderViewframe];
    [dashboardHeaderView.sendButton addTarget:self action:@selector(p_handleSend:) forControlEvents:UIControlEventTouchUpInside];
    [dashboardHeaderView.receiveButton addTarget:self action:@selector(p_handleReceive:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableHeaderView = dashboardHeaderView;
    
    // test
    // fake data
    for (NSInteger i = 0; i < 20; i++) {
        [self.transactions addObject:[Transaction new]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
#pragma mark Navigation

/// present profile
- (void)p_handleProfile:(id)sender {
    ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

/// push address list
- (void)p_handleAddressList:(id)sender {
    AddressListViewController *addressListViewController = [[AddressListViewController alloc] init];
    [self.navigationController pushViewController:addressListViewController animated:YES];
}

/// present scan
- (void)p_handleScan:(id)sender {
    ImagePickerController *imagePickerViewController = [[ImagePickerController alloc] init];
    [self presentViewController:imagePickerViewController animated:YES completion:nil];
}

/// push transactions
- (void)p_handleTransactionList:(id)sender {
    TransactionListViewController *transactionListViewController = [[TransactionListViewController alloc] init];
    [self.navigationController pushViewController:transactionListViewController animated:YES];
}

/// push send
- (void)p_handleSend:(id)sender {
    SendViewController *sendViewController = [[SendViewController alloc] init];
    [self.navigationController pushViewController:sendViewController animated:YES];
}

/// push address list to receive
- (void)p_handleReceive:(id)sender {
    AddressListViewController *addressListViewController = [[AddressListViewController alloc] init];
    addressListViewController.actionType = AddressActionTypeReceive;
    [self.navigationController pushViewController:addressListViewController animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.transactions.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedStringFromTable(@"Today", @"BTCC", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseListViewCellTransactionIdentifier forIndexPath:indexPath];
    Transaction *transaction = [self.transactions objectAtIndex:indexPath.row];
    if (transaction) {
        [cell setTransaction:transaction];
    }
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return BTCCCellHeightTransaction;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Transaction *transaction = [self.transactions objectAtIndex:indexPath.row];
    if (transaction) {
        TransactionViewController *transactionViewController = [[TransactionViewController alloc] initWithTransaction:transaction];
        [self.navigationController pushViewController:transactionViewController animated:YES];
    }
}

@end
