//
//  DashboardViewController.m
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

// TODO: 获取批量获取地址摘要信息，对比 tx count，如果发生变化（变多），则获取最新交易信息，page size = MIN(delta, maxSize)
// TODO: 将新交易重新排序后缓存，刷新UI

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
#import "CBWRequest.h"

#import "NSString+CBWAddress.h"

@interface DashboardViewController ()<ProfileViewControllerDelegate>

@property (nonatomic, strong) AccountStore *accountStore;
@property (nonatomic, strong) TransactionStore *transactionStore;
@property (nonatomic, strong) Account *account;
@property (nonatomic, weak) DashboardHeaderView *headerView;

@end

@implementation DashboardViewController

#pragma mark - Property

- (AccountStore *)accountStore {
    if (!_accountStore) {
        _accountStore = [[AccountStore alloc] init];
        [_accountStore fetch];
    }
    return _accountStore;
}

- (TransactionStore *)transactionStore {
    if (!_transactionStore) {
        // TODO: transaction store 可以指定 account 而不是 address
        _transactionStore = [TransactionStore new];
        [_transactionStore fetch];
    }
    return _transactionStore;
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
    
    
    
    [self reload];
}

#pragma mark - Public Method
- (void)reload {
    [self.accountStore fetch];
    // set default account
    // TODO: save to get last selected account
    if (!self.account) {
        self.account = [self.accountStore customDefaultAccount];
        DLog(@"dashboard reloaded account: %@", self.account);
    }
    
//    [self.tableView reloadData];
    
    [self reloadTransactions];
}

- (void)reloadTransactions {
    
    if (!self.account) {
        return;
    }
    
    if (self.requesting) {
        return;
    }
    
    [self.transactionStore flush];
    [self.tableView reloadData];
    
    [self requestDidStart];
    
    CBWRequest *request = [CBWRequest new];
    // 根据账号地址获取交易
    AddressStore *addressStore = [[AddressStore alloc] initWithAccountIdx:self.account.idx];
    [addressStore fetch];
    [request addressSummariesWithAddressStrings:addressStore.allAddressStrings completion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
        [self requestDidStop];
        if (!error) {
            // 找到交易变化的地址
            __block NSMutableArray *updatedAddresses = [NSMutableArray array];
            __block NSMutableArray *unupdatedAddresses = [NSMutableArray array];
            if ([response isKindOfClass:[NSArray class]]) {
                [response enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (![obj isKindOfClass:[NSNull class]]) {
                        
                        NSDictionary *responsedAddress = obj;
                        NSString *addressString = [responsedAddress objectForKey:@"address"];
                        Address *address = [addressStore addressWithAddressString:addressString];
                        NSUInteger responsedTxCount = [[responsedAddress objectForKey:@"tx_count"] unsignedIntegerValue];
                        if (responsedTxCount > address.txCount) {
                            [updatedAddresses addObject:addressString];
                        } else {
                            [unupdatedAddresses addObject:addressString];
                        }
                        
                    }
                }];
            }
            
            // 拉取交易列表
//            NSArray *addresses = updatedAddresses.count > 0 ? updatedAddresses : unupdatedAddresses;
            [updatedAddresses addObjectsFromArray:unupdatedAddresses];// 暂时没有缓存逻辑，全部拉取
            NSArray *addresses = [updatedAddresses copy];
            if (addresses.count > 0) {
                DLog(@"try to load transactions with addresses: %@", addresses);
                
                // fetch
                [request addressTransactionsWithAddressStrings:addresses completion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
                    if (!error) {
                        DLog(@"fetched transactions count: %lu", [[response objectForKey:@"total_count"] unsignedIntegerValue]);
                        
                        // 解析交易
                        [self.transactionStore addTransactionsFromJsonObject:[response objectForKey:@"list"]];
                        [self.transactionStore sort];
                        
                        // 更新界面
                        if ([self.tableView numberOfSections] == 0) {
                            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
                        } else {
                            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                        }
                    }
                }];
            }
            
            // 更新地址
            [addressStore updateAddresses:response];
        }
    }];
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

#pragma mark -

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.transactionStore.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedStringFromTable(@"Today", @"CBW", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseListViewCellTransactionIdentifier forIndexPath:indexPath];
    Transaction *transaction = [self.transactionStore recordAtIndex:indexPath.row];
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
    Transaction *transaction = [self.transactionStore recordAtIndex:indexPath.row];
    if (transaction) {
        TransactionViewController *transactionViewController = [[TransactionViewController alloc] initWithTransaction:transaction];
        [self.navigationController pushViewController:transactionViewController animated:YES];
    }
}

#pragma mark - ProfileViewControllerDelegate
- (void)profileViewController:(ProfileViewController *)viewController didSelectAccount:(Account *)account {
    DLog(@"dashboard selected account: %@", account);
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([account isEqual:self.account]) {
        return;
    }
    self.account = account;
    self.headerView.sendButton.enabled = self.account.idx >= 0;
    [self reloadTransactions];
}

@end
