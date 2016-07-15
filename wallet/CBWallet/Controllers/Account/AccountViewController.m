//
//  AccountViewController.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

// FIXME: 更新地址余额不需要触发 iCloud 同步
// TODO: watched account 不存在内部转移交易

#import "AccountViewController.h"
#import "SWRevealViewController.h"
#import "AddressListViewController.h"// explorer or receive
#import "ScanViewController.h"// scan to explorer or send
#import "TransactionListViewController.h"// list all transactions
#import "TransactionViewController.h" // transaction detail
#import "SendViewController.h"// send

#import "AccountHeaderView.h"
#import "AccountNavigationTitleView.h"

#import "Guard.h"
#import "Database.h"
#import "CBWRequest.h"

#import "BlockMonitor.h"

#import "NSString+CBWAddress.h"
#import "NSDate+Helper.h"

@interface AccountViewController ()<AddressListViewControllerDelegate, ScanViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) CBWAccountStore *accountStore;
@property (nonatomic, strong) CBWTXStore *transactionStore;
@property (nonatomic, strong) CBWAccount *account;
@property (nonatomic, weak) AccountHeaderView *headerView;
@property (nonatomic, assign) BOOL isThereMoreDatas;

@property (nonatomic, assign, getter=isVisible) BOOL visible;
@property (nonatomic, assign, getter=isNeededToRefresh) BOOL neededToRefresh;

/// navigation bar title view
@property (nonatomic, weak) AccountNavigationTitleView *balanceTitleView;

@end

@implementation AccountViewController
@synthesize title = _title, userInteractionDisabled = _userInteractionDisabled;

#pragma mark - Property

- (void)setUserInteractionDisabled:(BOOL)userInteractionDisabled {
    _userInteractionDisabled = userInteractionDisabled;
    self.headerView.userInteractionEnabled = !userInteractionDisabled;
}

- (AccountNavigationTitleView *)balanceTitleView {
    if (!_balanceTitleView) {
        AccountNavigationTitleView *view = [[AccountNavigationTitleView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        self.navigationItem.titleView = view;
        _balanceTitleView = view;
    }
    return _balanceTitleView;
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    self.balanceTitleView.title = title;
}

- (CBWAccountStore *)accountStore {
    if (!_accountStore) {
        _accountStore = [[CBWAccountStore alloc] init];
    }
    return _accountStore;
}

- (CBWTXStore *)transactionStore {
    if (!_transactionStore) {
        _transactionStore = [CBWTXStore new];
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
        self.headerView.sendButton.enabled = _account.idx != CBWRecordWatchedIDX;
        self.headerView.receiveButton.enabled = _account.idx != CBWRecordWatchedIDX;
        
        [self.transactionStore flush];
        [self.tableView reloadData];
       
        [self sync];
    }
}

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = NSLocalizedStringFromTable(@"Navigation account", @"CBW", @"Account");
    
    // reveal view controller
    SWRevealViewController *revealViewController = [self revealViewController];
    [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:revealViewController.tapGestureRecognizer];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"navigation_drawer"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:revealViewController action:@selector(revealToggle:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_book"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleAddressList:)];
    
    [self p_registerNotifications];
    
    
    // set table header
    CGFloat offsetHeight = -64.f;// status bar height + navigation bar height
    CGRect accountHeaderViewframe = self.view.bounds;
    accountHeaderViewframe.size.height = roundf(CGRectGetWidth(accountHeaderViewframe) / 16.f * 9.f) + offsetHeight;
    AccountHeaderView *accountHeaderView = [[AccountHeaderView alloc] initWithFrame:accountHeaderViewframe];
    [accountHeaderView.sendButton addTarget:self action:@selector(p_handleSend:) forControlEvents:UIControlEventTouchUpInside];
    [accountHeaderView.receiveButton addTarget:self action:@selector(p_handleReceive:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableHeaderView = accountHeaderView;
    _headerView = accountHeaderView;
    
    if (!self.refreshControl) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(sync) forControlEvents:UIControlEventValueChanged];
    }
    
    [[BlockMonitor defaultMonitor] begin];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_handleNotification:) name:BlockMonitorNotificationNewBlock object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.visible = YES;
    if (self.isNeededToRefresh) {
        [self.tableView reloadData];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.visible = NO;
}

#pragma mark - Public Method
- (void)reload {
    [self.accountStore fetch];
    if (self.accountStore.count == 0) {
        NSLog(@"try to load with out any account");
        return;
    }
    // set default account
    // TODO: save to get last selected account
    if (!self.account) {
        self.account = [self.accountStore customDefaultAccount];
        DLog(@"reloaded account: %@", self.account);
    } else {
        [self sync];
    }
    
    [self reloadTransactions];
}

- (void)sync {
    CBWAddressStore *addressStore = [[CBWAddressStore alloc] initWithAccountIdx:self.account.idx];
    [addressStore fetch];
    self.balanceTitleView.balance = [@(addressStore.totalBalance) satoshiBTCString];
    DLog(@"account sync with addresses: %@", addressStore.allAddressStrings);
    
    if (addressStore.allAddressStrings.count == 0) {
        DLog(@"no address to fetch");
        [self.refreshControl endRefreshing];
        return;
    }
    
    // transaction
    CBWTransactionSync *sync = [[CBWTransactionSync alloc] init];
    sync.accountIDX = self.account.idx;
    [sync syncWithAddresses:addressStore.allAddressStrings progress:^(NSString *message) {
        DLog(@"sync progress: \n%@", message);
    } completion:^(NSError *error, NSDictionary<NSString *,NSDictionary<NSString *,NSNumber *> *> *updatedAddresses) {
        DLog(@"sync done: \n%@", updatedAddresses);
        [self.refreshControl endRefreshing];
        
        if (updatedAddresses == 0) {
            DLog(@"no need to update");
            return;
        }
        
        __block BOOL needUpdate = NO;
        [updatedAddresses enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary<NSString *,NSNumber *> * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
                if (obj.integerValue > 0) {
                    needUpdate = YES;
                    *stop = YES;
                }
            }];
            if (needUpdate) {
                *stop = YES;
            }
        }];
        if (needUpdate) {
            [self reloadTransactions];
            return;
        }
        DLog(@"checked, no need to update");
    }];
    
    // summary
    CBWRequest *request = [[CBWRequest alloc] init];
    [request addressSummariesWithAddressStrings:addressStore.allAddressStrings completion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
        [addressStore updateAddresses:response];
    }];
}

- (void)reloadTransactions {
    
    if (!self.account) {
        return;
    }
    
    // 1. get account address list
    CBWAddressStore *addressStore = [[CBWAddressStore alloc] initWithAccountIdx:self.account.idx];
    [addressStore fetch];
    self.balanceTitleView.balance = [@(addressStore.totalBalance) satoshiBTCString];
    DLog(@"account reload transactions with addresses: %@", addressStore.allAddressStrings);
    
    if (addressStore.allAddressStrings.count == 0) {
        DLog(@"no address to fetch");
        [self.refreshControl endRefreshing];
        return;
    }
    
    // 指定查询地址
//    if (self.account.idx != CBWRecordWatchedIDX) {
        self.transactionStore.queryAddresses = addressStore.allAddressStrings;
//    }
    self.transactionStore.accountIDX = self.account.idx;
    [self.transactionStore fetch];
    [self.tableView reloadData];
}

#pragma mark - Private Method

- (void)p_registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_handleNotification:) name:CBWNotificationCheckedIn object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_handleNotification:) name:CBWNotificationCheckedOut object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_handleNotification:) name:CBWNotificationWalletCreated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_handleNotification:) name:CBWNotificationWalletRecovered object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_handleNotification:) name:CBWNotificationSignedOut object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_handleNotification:) name:CBWNotificationTransactionCreated object:nil];
}

- (void)p_handleNotification:(NSNotification *)notification {
    DLog(@"notification: %@", notification);
    if ([notification.name isEqualToString:CBWNotificationCheckedIn]) {
        // TODO: 区分 launch 时的 check in
        [self reload];
    } else if ([notification.name isEqualToString:CBWNotificationWalletCreated]) {
        [self reload];
    } else if ([notification.name isEqualToString:CBWNotificationWalletRecovered]) {
        [self reload];
    } else if ([notification.name isEqualToString:CBWNotificationTransactionCreated]) {
        [self reload];
    } else if ([notification.name isEqualToString:CBWNotificationSignedOut]) {
        [self p_handleSignOut];
    } else if ([notification.name isEqualToString:BlockMonitorNotificationNewBlock]) {
        DLog(@"new block height: %lu", (unsigned long)[BlockMonitor defaultMonitor].height);
        if (self.accountStore.count == 0) {
            return;
        }
        
        [self sync];
        if (self.isVisible) {
            [self.tableView reloadData];
        } else {
            self.neededToRefresh = YES;
        }
    }
}

#pragma mark Navigation

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

/// signed out
- (void)p_handleSignOut {
    DLog(@"sign out \n-------");
    self.account = nil;
    [self.accountStore flush];
    [self.transactionStore flush];
    // 更新界面
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    return [self.transactionStore numberOfRowsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDate *today = [NSDate date];
    NSString *day = [self.transactionStore dayInSection:section];
    if ([today isInSameDayWithDate:[NSDate dateFromString:day withFormat:self.transactionStore.dateFormat]]) {
        return NSLocalizedStringFromTable(@"Today", @"CBW", nil);
    }
    return day;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseListViewCellTransactionIdentifier forIndexPath:indexPath];
    CBWTransaction *transaction = [self.transactionStore transactionAtIndexPath:indexPath];
    transaction.latestBlockHeight = [BlockMonitor defaultMonitor].height;
    if (transaction) {
        [cell setTransaction:transaction];
    }
    return cell;
}

#pragma mark <UITableViewDelegate>
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CBWListSectionHeaderHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CBWCellHeightTransaction;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBWTransaction *transaction = [self.transactionStore transactionAtIndexPath:indexPath];
    if (transaction) {
        TransactionViewController *transactionViewController = [[TransactionViewController alloc] initWithTransaction:transaction];
        [self.navigationController pushViewController:transactionViewController animated:YES];
    }
}

#pragma mark - <AddressListViewControllerDelegate>
- (void)addressListViewControllerDidUpdate:(AddressListViewController *)controller {
    DLog(@"address list did update");
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
    if (self.account.idx == CBWRecordWatchedIDX) {
        // create watched address
        NSString *label = [addressInfo objectForKey:CBWAddressInfoLabelKey];
        DLog(@"To create address: %@ labeled: %@", addressString, label);
        
        CBWAddressStore *addressStore = [[CBWAddressStore alloc] initWithAccountIdx:self.account.idx];
        [addressStore fetch];
        CBWAddress *address = [CBWAddress newAdress:addressString withLabel:label idx:CBWRecordWatchedIDX accountRid:self.account.rid accountIdx:self.account.idx inStore:addressStore];
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

#pragma mark <UIScrollViewDelegate>
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.transactionStore.page < self.transactionStore.pageTotal) {
        CGFloat contentHeight = scrollView.contentSize.height;
        CGFloat offsetTop = targetContentOffset->y;
        CGFloat height = CGRectGetHeight(scrollView.frame);
        if (contentHeight - (offsetTop + height) < 200.f) {
            [self.transactionStore fetchNextPage];
            [self.tableView reloadData];
        }
    }
}

@end
