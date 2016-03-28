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

#import "Guard.h"
#import "Database.h"

#import "NSString+CBWAddress.h"

@interface DashboardViewController ()<ProfileViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *transactions; // of Transaction
@property (nonatomic, strong) AccountStore *accountStore;
@property (nonatomic, strong) Account *account;
@property (nonatomic, weak) DashboardHeaderView *headerView;

@end

@implementation DashboardViewController

#pragma mark - Property
- (NSMutableArray *)transactions {
    if (!_transactions) {
        _transactions = [[NSMutableArray alloc] init];
    }
    return _transactions;
}

- (AccountStore *)accountStore {
    if (!_accountStore) {
        _accountStore = [[AccountStore alloc] init];
        [_accountStore fetch];
    }
    return _accountStore;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = NSLocalizedStringFromTable(@"Navigation dashboard", @"CBW", @"Dashboard");
    
    // set navigation buttons
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"navigation_drawer"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleProfile:)];
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_address"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleAddressList:)], [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"navigation_scan"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleScan:)]];
    
    
    [self p_registerNotifications];
    
    
    // set table header
    CGFloat offsetHeight = -64.f;// status bar height + navigation bar height
    CGRect dashboardHeaderViewframe = self.view.bounds;
    dashboardHeaderViewframe.size.height = roundf(CGRectGetWidth(dashboardHeaderViewframe) / 16.f * 9.f) + offsetHeight;
    DashboardHeaderView *dashboardHeaderView = [[DashboardHeaderView alloc] initWithFrame:dashboardHeaderViewframe];
    [dashboardHeaderView.sendButton addTarget:self action:@selector(p_handleSend:) forControlEvents:UIControlEventTouchUpInside];
    [dashboardHeaderView.receiveButton addTarget:self action:@selector(p_handleReceive:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableHeaderView = dashboardHeaderView;
    _headerView = dashboardHeaderView;
    
    if (!self.account) {
        self.account = [self.accountStore customDefaultAccount];
        DLog(@"dashboard initial account: %@", self.account);
    }
}

#pragma mark - Public Method
- (void)reload {
    [self.accountStore fetch];
    if (!self.account) {
        self.account = [self.accountStore customDefaultAccount];
        DLog(@"dashboard reloaded account: %@", self.account);
    }
    [self reloadTransactions];
}

- (void)reloadTransactions {
    self.headerView.sendButton.enabled = self.account.idx >= 0;
    [self.tableView reloadData];
}

#pragma mark - Private Method

- (void)p_registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:CBWNotificationCheckedIn object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:CBWNotificationCheckedOut object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:CBWNotificationWalletCreated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:CBWNotificationWalletRecovered object:nil];
}
#pragma mark Navigation

/// present profile
- (void)p_handleProfile:(id)sender {
    ProfileViewController *profileViewController = [[ProfileViewController alloc] initWithAccountStore:self.accountStore];
    profileViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

/// push address list
- (void)p_handleAddressList:(id)sender {
    AddressListViewController *addressListViewController = [[AddressListViewController alloc] initWithAccount:self.account];
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
    AddressListViewController *addressListViewController = [[AddressListViewController alloc] initWithAccount:self.account];
    addressListViewController.actionType = AddressActionTypeReceive;
    [self.navigationController pushViewController:addressListViewController animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.transactions.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedStringFromTable(@"Today", @"CBW", nil);
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
    return CBWCellHeightTransaction;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Transaction *transaction = [self.transactions objectAtIndex:indexPath.row];
    if (transaction) {
        TransactionViewController *transactionViewController = [[TransactionViewController alloc] initWithTransaction:transaction];
        [self.navigationController pushViewController:transactionViewController animated:YES];
    }
}

#pragma mark - ProfileViewControllerDelegate
- (void)profileViewController:(ProfileViewController *)viewController didSelectAccount:(Account *)account {
    DLog(@"dashboard selected account: %@", account);
    if ([account isEqual:self.account]) {
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    self.account = account;
    [self reloadTransactions];
}

@end
