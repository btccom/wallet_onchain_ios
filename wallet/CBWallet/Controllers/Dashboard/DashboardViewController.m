//
//  DashboardViewController.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

// TODO: 获取批量获取地址摘要信息，对比 tx count，如果发生变化（变多），则获取最新交易信息，page size = MIN(delta, maxSize)
// TODO: 将新交易重新排序后缓存，刷新UI
// TODO: 使用唯一的 address store，address store 使用单例模式，通过设置 account 改变数据

#import "DashboardViewController.h"
#import "ProfileViewController.h"
#import "AddressListViewController.h"// explorer or receive
#import "ScanViewController.h"// scan to explorer or send
#import "TransactionListViewController.h"// list all transactions
#import "TransactionViewController.h" // transaction detail
#import "SendViewController.h"// send

#import "DashboardHeaderView.h"

#import "Guard.h"
#import "Database.h"
#import "CBWRequest.h"

#import "NSString+CBWAddress.h"
#import "NSDate+Helper.h"

@interface DashboardViewController ()<ProfileViewControllerDelegate, AddressListViewControllerDelegate, ScanViewControllerDelegate>

@property (nonatomic, strong) CBWAccountStore *accountStore;
@property (nonatomic, strong) CBWTransactionStore *transactionStore;
@property (nonatomic, strong) CBWAccount *account;
@property (nonatomic, weak) DashboardHeaderView *headerView;
@property (nonatomic, assign) BOOL isThereMoreDatas;

@end

@implementation DashboardViewController

#pragma mark - Property

- (CBWAccountStore *)accountStore {
    if (!_accountStore) {
        _accountStore = [[CBWAccountStore alloc] init];
        [_accountStore fetch];
    }
    return _accountStore;
}

- (CBWTransactionStore *)transactionStore {
    if (!_transactionStore) {
        // TODO: transaction store 可以指定 account 而不是 address
        _transactionStore = [CBWTransactionStore new];
        [_transactionStore fetch];
    }
    return _transactionStore;
}

- (void)setAccount:(CBWAccount *)account {
    if (![_account isEqual:account]) {
        if (_account) {
            [_account removeObserver:self forKeyPath:@"label"];
        }
        _account = account;
        [_account addObserver:self forKeyPath:@"label" options: NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = NSLocalizedStringFromTable(@"Navigation dashboard", @"CBW", @"Dashboard");
    // set navigation buttons
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"navigation_wallet"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleProfile:)];
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_list"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleAddressList:)], [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"navigation_scan"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleScan:)]];
    
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
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedStringFromTable(@"Tip loading", @"CBW", nil) attributes:@{NSForegroundColorAttributeName: [UIColor CBWSubTextColor]}];
    self.refreshControl.tintColor = [UIColor CBWSubTextColor];
    [self.refreshControl addTarget:self action:@selector(reloadTransactions) forControlEvents:UIControlEventValueChanged];
    
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
    
    self.transactionStore.account = self.account;
    
    if (self.requesting) {
        // TODO: 停止之前的请求
        [self requestDidStop];
    }
    
    // reset
    [self.transactionStore flush];
    self.isThereMoreDatas = NO;
    [self.tableView reloadData];
    
    // start request
    [self requestDidStart];
    
    CBWRequest *request = [CBWRequest new];
    // 根据账号地址获取交易
    CBWAddressStore *addressStore = [[CBWAddressStore alloc] initWithAccountIdx:self.account.idx];
    [addressStore fetch];
    DLog(@"dashboard all addresses: %@", addressStore.allAddressStrings);
    [request addressSummariesWithAddressStrings:addressStore.allAddressStrings completion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
        if (error) {
            [self requestDidStop];
        } else {
            // 找到交易变化的地址
            __block NSMutableArray *updatedAddresses = [NSMutableArray array];
            __block NSMutableArray *unupdatedAddresses = [NSMutableArray array];
            if ([response isKindOfClass:[NSArray class]]) {
                [response enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (![obj isKindOfClass:[NSNull class]]) {
                        
                        NSDictionary *responsedAddress = obj;
                        NSString *addressString = [responsedAddress objectForKey:@"address"];
                        CBWAddress *address = [addressStore addressWithAddressString:addressString];
                        NSUInteger responsedTxCount = [[responsedAddress objectForKey:@"tx_count"] unsignedIntegerValue];
                        if (responsedTxCount == address.txCount) {
                            [unupdatedAddresses addObject:addressString];
                        } else {
                            [updatedAddresses addObject:addressString];
                        }
                        
                    }
                }];
            } else if ([response isKindOfClass:[NSDictionary class]]) {
                // 只有一个结果
                NSString *addressString = [response objectForKey:@"address"];
                CBWAddress *address = [addressStore addressWithAddressString:addressString];
                NSUInteger responsedTxCount = [[response objectForKey:@"tx_count"] unsignedIntegerValue];
                if (responsedTxCount == address.txCount) {
                    [unupdatedAddresses addObject:addressString];
                } else {
                    [updatedAddresses addObject:addressString];
                }
            }
            
            // 拉取交易列表
//            NSArray *addresses = updatedAddresses.count > 0 ? updatedAddresses : unupdatedAddresses;
            [updatedAddresses addObjectsFromArray:unupdatedAddresses];// 暂时没有缓存逻辑，全部拉取
            NSArray *addresses = [updatedAddresses copy];
            if (addresses.count > 0) {
                DLog(@"try to load transactions with addresses: %@", addresses);
                
                // fetch
                [request addressTransactionsWithAddressStrings:addresses completion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
                    [self requestDidStop];
                    if (!error) {
                        // 分页
                        NSUInteger totalCount = [[response objectForKey:CBWRequestResponseDataTotalCountKey] unsignedIntegerValue];
                        NSUInteger pageSize = [[response objectForKey:CBWRequestResponseDataPageSizeKey] unsignedIntegerValue];
                        NSUInteger page = [[response objectForKey:CBWRequestResponseDataPageKey] unsignedIntegerValue];
                        self.isThereMoreDatas = totalCount > pageSize * page;
                        
                        DLog(@"fetched transactions page: %lu, page size: %lu, total: %lu", page, pageSize, totalCount);
                        
                        // 解析交易
                        [self.transactionStore addTransactionsFromJsonObject:[response objectForKey:CBWRequestResponseDataListKey] isCacheNeeded:(page == 1)];
//                        [self.transactionStore sort];
                        
                        // 更新界面
                        if ([self.tableView numberOfSections] == 0) {
//                            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
                            [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.transactionStore.numberOfSections)] withRowAnimation:UITableViewRowAnimationTop];
                        } else {
//                            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                            [self.tableView reloadData];
                        }
                        
                        [self.refreshControl endRefreshing];
                    }
                }];
                
                // 更新地址
                [addressStore updateAddresses:response];
                
            } else {
                [self requestDidStop];
            }
            
            
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
    addressListViewController.delegate = self;
    [self.navigationController pushViewController:addressListViewController animated:YES];
}

/// present scan
- (void)p_handleScan:(id)sender {
    ScanViewController *imagePickerViewController = [[ScanViewController alloc] init];
    imagePickerViewController.delegate = self;
    [self presentViewController:imagePickerViewController animated:YES completion:nil];
}

/// push transactions
- (void)p_handleTransactionList:(id)sender {
    TransactionListViewController *transactionListViewController = [[TransactionListViewController alloc] init];
    [self.navigationController pushViewController:transactionListViewController animated:YES];
}

/// push send
- (void)p_handleSend:(id)sender {
    SendViewController *sendViewController = [[SendViewController alloc] initWithAccount:self.account];
    sendViewController.mode = SendViewControllerModeQuickly;
    [self.navigationController pushViewController:sendViewController animated:YES];
}

/// push address list to receive
- (void)p_handleReceive:(id)sender {
    AddressListViewController *addressListViewController = [[AddressListViewController alloc] initWithAccount:self.account];
    addressListViewController.actionType = AddressActionTypeReceive;
    [self.navigationController pushViewController:addressListViewController animated:YES];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"label"]) {
        DLog(@"label changed: %@", change);
        self.title = [change objectForKey:NSKeyValueChangeNewKey];
    }
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.transactionStore numberOfSections];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.transactionStore.count;
    return [self.transactionStore numberOfRowsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return NSLocalizedStringFromTable(@"Today", @"CBW", nil);
    NSDate *today = [NSDate date];
    NSString *day = [self.transactionStore dayInSection:section];
    if ([today isInSameDayWithDate:[NSDate dateFromString:day withFormat:@"yyyy-MM-dd"]]) {
        return NSLocalizedStringFromTable(@"Today", @"CBW", nil);
    }
    return day;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseListViewCellTransactionIdentifier forIndexPath:indexPath];
//    CBWTransaction *transaction = [self.transactionStore recordAtIndex:indexPath.row];
    CBWTransaction *transaction = [self.transactionStore transactionAtIndexPath:indexPath];
    if (transaction) {
        [cell setTransaction:transaction];
    }
    return cell;
}

#pragma mark <UITableViewDelegate>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CBWCellHeightTransaction;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBWTransaction *transaction = [self.transactionStore recordAtIndex:indexPath.row];
    if (transaction) {
        TransactionViewController *transactionViewController = [[TransactionViewController alloc] initWithTransaction:transaction];
        [self.navigationController pushViewController:transactionViewController animated:YES];
    }
}

#pragma mark - <ProfileViewControllerDelegate>
- (void)profileViewController:(ProfileViewController *)viewController didSelectAccount:(CBWAccount *)account {
    DLog(@"dashboard selected account: %@", account);
    
    self.account = account;
    [self reloadTransactions];
    self.headerView.sendButton.enabled = self.account.idx >= 0;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <AddressListViewControllerDelegate>
- (void)addressListViewControllerDidUpdate:(AddressListViewController *)controller {
    NSLog(@"address list did update");
    [self reloadTransactions];
}

#pragma mark - <ScanViewControllerDelegate>
- (BOOL)scanViewControllerWillDismiss:(ScanViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    return YES;
}

- (void)scanViewController:(ScanViewController *)viewController didScanString:(NSString *)string {
    [self dismissViewControllerAnimated:YES completion:nil];
    // decode qr code string
    NSDictionary *addressInfo = [string addressInfo];
    if (!addressInfo) {
        [self alertMessageWithInvalidAddress:nil];
        return;
    }
    // check address
    NSString *addressString = [addressInfo objectForKey:CBWAddressInfoAddressKey];
    if (![CBWAddress validateAddressString:addressString]) {
        [self alertMessageWithInvalidAddress:addressString];
    }
    // handle
    if (self.account.idx == CBWRecordWatchedIdx) {
        // create watched address
        NSString *label = [addressInfo objectForKey:CBWAddressInfoLabelKey];
        DLog(@"To create address: %@ labeled: %@", addressString, label);
        
        CBWAddressStore *store = [[CBWAddressStore alloc] initWithAccountIdx:self.account.idx];
        [store fetch];
        CBWAddress *address = [CBWAddress newAdress:addressString withLabel:label idx:CBWRecordWatchedIdx accountRid:self.account.rid accountIdx:self.account.idx inStore:store];
        NSError *error = nil;
        [address saveWithError:&error];
        if (!error) {
            [self alertMessage:NSLocalizedStringFromTable(@"Alert Message create_watched_address_success", @"CBW", nil) withTitle:NSLocalizedStringFromTable(@"Success", @"CBW", nil)];
            [self reloadTransactions];
        }
    } else {
        // send to address
        NSString *amountString = [addressInfo objectForKey:CBWAddressInfoAmountKey];
        SendViewController *sendViewController = [[SendViewController alloc] initWithAccount:self.account];
        sendViewController.quicklyToAddress = addressString;
        sendViewController.quicklyToAmountInBTC = amountString;
        [self.navigationController pushViewController:sendViewController animated:YES];
    }
}

@end
