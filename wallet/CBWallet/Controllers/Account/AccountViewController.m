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
#import "AddressListViewController.h"// explorer or receive
//#import "ScanViewController.h"// scan to explorer or send
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

@interface AccountViewController ()<AddressListViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) CBWAccount *account;
@property (nonatomic, strong) CBWTXStore *transactionStore;
@property (nonatomic, weak) AccountHeaderView *headerView;
@property (nonatomic, assign) BOOL isThereMoreDatas;

@property (nonatomic, assign, getter=isVisible) BOOL visible;
@property (nonatomic, assign, getter=isNeededToRefresh) BOOL neededToRefresh;

@property (nonatomic, assign, getter=isSynced) BOOL synced;

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

- (CBWTXStore *)transactionStore {
    if (!_transactionStore) {
        _transactionStore = [CBWTXStore new];
    }
    return _transactionStore;
}

#pragma mark - View Life Cycle

- (instancetype)initWithAccount:(CBWAccount *)account {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        if (!account) {
            return nil;
        }
        _account = account;
    }
    return self;
}
- (instancetype)initWithStyle:(UITableViewStyle)style {
    return nil;
}
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = self.account.label;
    
    // navigation
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_book"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleAddressList:)];
    [self enableRevealInteraction];
    
    // set table header
    CGFloat offsetHeight = -64.f;// status bar height + navigation bar height
    CGRect accountHeaderViewframe = self.view.bounds;
    accountHeaderViewframe.size.height = roundf(CGRectGetWidth(accountHeaderViewframe) / 16.f * 9.f) + offsetHeight;
    AccountHeaderView *accountHeaderView = [[AccountHeaderView alloc] initWithFrame:accountHeaderViewframe];
    [accountHeaderView.sendButton addTarget:self action:@selector(p_handleSend:) forControlEvents:UIControlEventTouchUpInside];
    [accountHeaderView.receiveButton addTarget:self action:@selector(p_handleReceive:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableHeaderView = accountHeaderView;
    _headerView = accountHeaderView;
    
    // refresh control
    if (!self.refreshControl) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(sync) forControlEvents:UIControlEventValueChanged];
    }
    
    // notifications
    [self p_registerNotifications];
    
    // account and data
    self.headerView.sendButton.enabled = self.account.idx != CBWRecordWatchedIDX;
    self.headerView.receiveButton.enabled = self.headerView.sendButton.enabled;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self reloadTransactions];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.visible = YES;
    if (self.isNeededToRefresh) {
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.isSynced) {
        [self sync];
        _synced = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.visible = NO;
}

#pragma mark - Public Method
- (void)sync {
    if (!self.account) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self p_sync];
    });
}

- (void)reloadTransactions {
    
    if (!self.account) {
        return;
    }
    
    // 1. get account address list
    CBWAddressStore *addressStore = [[CBWAddressStore alloc] initWithAccountIdx:self.account.idx];
    [addressStore fetch];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.balanceTitleView.balance = [@(addressStore.totalBalance) satoshiBTCString];
    });
    DLog(@"account reload transactions with addresses: %@", addressStore.allAddressStrings);
    
    if (addressStore.allAddressStrings.count == 0) {
        DLog(@"no address to fetch");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
        });
        return;
    }
    
    // 指定查询地址
//    if (self.account.idx != CBWRecordWatchedIDX) {
        self.transactionStore.queryAddresses = addressStore.allAddressStrings;
//    }
    self.transactionStore.accountIDX = self.account.idx;
    [self.transactionStore fetch];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CBWNotificationTransactionCreated object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BlockMonitorNotificationNewBlock object:nil];
}

#pragma mark - Private Method

- (void)p_registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_handleNotification:) name:CBWNotificationTransactionCreated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_handleNotification:) name:BlockMonitorNotificationNewBlock object:nil];
}

- (void)p_handleNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:CBWNotificationTransactionCreated]) {
        [self sync];
    } else if ([notification.name isEqualToString:BlockMonitorNotificationNewBlock]) {
        DLog(@"new block height: %lu", (unsigned long)[BlockMonitor defaultMonitor].height);
        
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

///// present scan
//- (void)p_handleScan:(id)sender {
//    ScanViewController *imagePickerViewController = [[ScanViewController alloc] init];
//    imagePickerViewController.delegate = self;
//    [self presentViewController:imagePickerViewController animated:YES completion:nil];
//}

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

- (void)p_sync {
    CBWAddressStore *addressStore = [[CBWAddressStore alloc] initWithAccountIdx:self.account.idx];
    [addressStore fetch];
    DLog(@"account sync with addresses: %@", addressStore.allAddressStrings);
    
    if (addressStore.allAddressStrings.count == 0) {
        DLog(@"no address to fetch");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
        });
        return;
    }
    
    // transaction
    CBWTransactionSync *sync = [[CBWTransactionSync alloc] init];
    sync.accountIDX = self.account.idx;
    [sync syncWithAddresses:addressStore.allAddressStrings progress:^(NSString *message) {
        DLog(@"sync progress: \n%@", message);
    } completion:^(NSError *error, NSDictionary<NSString *,NSDictionary<NSString *,NSNumber *> *> *updatedAddresses) {
        DLog(@"sync done: \n%@", updatedAddresses);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
        });
        
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

//#pragma mark - <ScanViewControllerDelegate>
//- (BOOL)scanViewControllerWillDismiss:(ScanViewController *)viewController {
//    [self dismissViewControllerAnimated:YES completion:nil];
//    return YES;
//}
//
//- (void)scanViewController:(ScanViewController *)viewController didScanString:(NSString *)string {
//    [self dismissViewControllerAnimated:YES completion:nil];
//    // decode qr code string
//    NSDictionary *addressInfo = [string addressInfo];
//    if (!addressInfo) {
//        [self alertMessageWithInvalidAddress:nil];
//        return;
//    }
//    // check address
//    NSString *addressString = [addressInfo objectForKey:CBWAddressInfoAddressKey];
//    if (![CBWAddress validateAddressString:addressString]) {
//        [self alertMessageWithInvalidAddress:addressString];
//    }
//    // handle
//    if (self.account.idx == CBWRecordWatchedIDX) {
//        // create watched address
//        NSString *label = [addressInfo objectForKey:CBWAddressInfoLabelKey];
//        DLog(@"To create address: %@ labeled: %@", addressString, label);
//        
//        CBWAddressStore *addressStore = [[CBWAddressStore alloc] initWithAccountIdx:self.account.idx];
//        [addressStore fetch];
//        CBWAddress *address = [CBWAddress newAdress:addressString withLabel:label idx:CBWRecordWatchedIDX accountRid:self.account.rid accountIdx:self.account.idx inStore:addressStore];
//        NSError *error = nil;
//        [address saveWithError:&error];
//        if (!error) {
//            [self alertMessage:NSLocalizedStringFromTable(@"Alert Message create_watched_address_success", @"CBW", nil) withTitle:NSLocalizedStringFromTable(@"Success", @"CBW", nil)];
//            [self reloadTransactions];
//        }
//    } else {
//        // send to address
//        NSString *amountString = [addressInfo objectForKey:CBWAddressInfoAmountKey];
//        SendViewController *sendViewController = [[SendViewController alloc] initWithAccount:self.account];
//        sendViewController.quicklyToAddress = addressString;
//        sendViewController.quicklyToAmountInBTC = amountString;
//        [self.navigationController pushViewController:sendViewController animated:YES];
//    }
//}

#pragma mark <UIScrollViewDelegate>
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.transactionStore.page < self.transactionStore.pageTotal && self.transactionStore.queryAddresses.count > 0) {
        CGFloat contentHeight = scrollView.contentSize.height;
        CGFloat offsetTop = targetContentOffset->y;
        CGFloat height = CGRectGetHeight(scrollView.frame);
        if (contentHeight - (offsetTop + height) < 2 * CBWCellHeightTransaction) {
            [self.transactionStore fetchNextPage];
            [self.tableView reloadData];
        }
    }
}

@end
