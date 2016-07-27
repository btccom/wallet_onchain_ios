//
//  AddressExplorerViewController.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AddressExplorerViewController.h"
#import "TransactionViewController.h"

#import "AddressHeaderView.h"
#import "FormControlInputCell.h"

#import "Database.h"
#import "CBWRequest.h"
#import "BlockMonitor.h"

#import "CBWTransactionStore.h"

#import "NSDate+Helper.h"
#import "NSString+CBWAddress.h"

static NSString *const kAddressExplorerReceiveAmountCellIdentifier = @"cell.receive.amount";

@interface AddressExplorerViewController ()<AddressHeaderViewDelegate, UIScrollViewDelegate, CBWTransactionStoreDelegate>

@property (nonatomic, weak) AddressHeaderView *headerView;

@property (nonatomic, strong) CBWTransactionStore *transactionStore;
@property (nonatomic, assign) BOOL isThereMoreDatas;
@property (nonatomic, assign) NSInteger page;

@property (nonatomic, strong) NSString *addressString;

@end

@implementation AddressExplorerViewController

- (CBWTransactionStore *)transactionStore {
    if (!_transactionStore) {
        _transactionStore = [[CBWTransactionStore alloc] init];
        _transactionStore.addressString = self.addressString;
        _transactionStore.delegate = self;
    }
    return _transactionStore;
}

- (NSString *)addressString {
    if (!_addressString) {
        if (AddressActionTypeExplore == self.actionType) {
            _addressString = self.address.address;
        } else {
            _addressString = [[NSUserDefaults standardUserDefaults] boolForKey:CBWUserDefaultsTestnetEnabled] ? self.address.testAddress : self.address.address;
        }
    }
    return _addressString;
}

#pragma mark - Initialization

- (instancetype)initWithAddress:(CBWAddress *)address actionType:(AddressActionType)actionType {
    self = [super initWithStyle:(AddressActionTypeReceive == actionType) ? UITableViewStyleGrouped : UITableViewStylePlain];
    if (self) {
        _address = address;
        _actionType = actionType;
        NSAssert(AddressActionTypeReceive == actionType || AddressActionTypeExplore == actionType, @"Address explorer view controller won't support this action: %lu", actionType);
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return nil;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    return nil;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AddressHeaderView *addressHeaderView = [[AddressHeaderView alloc] init];
    [addressHeaderView setAddress:self.addressString withLabel:self.address.label];
    addressHeaderView.delegate = self;
    [self.tableView setTableHeaderView:addressHeaderView];
    _headerView = addressHeaderView;
    switch (self.actionType) {
            
        case AddressActionTypeReceive: {
            self.title = NSLocalizedStringFromTable(@"Navigation receive", @"CBW", @"Receive");
            [self.tableView registerClass:[FormControlInputCell class] forCellReuseIdentifier:kAddressExplorerReceiveAmountCellIdentifier];
            break;
        }
            
        case AddressActionTypeExplore: {
            self.title = NSLocalizedStringFromTable(@"Navigation address", @"CBW", @"Address");
            
            // right navigation item
            if (self.navigationController.viewControllers.count > 3) {
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(p_handleBackToRoot)];
            }
            
            if (!self.refreshControl) {
                self.refreshControl = [[UIRefreshControl alloc] init];
                [self.refreshControl addTarget:self action:@selector(p_requestAddressSummary) forControlEvents:UIControlEventValueChanged];
            }
            
            // 请求摘要及交易信息
            [self p_requestAddressSummary];
            break;
        }
        default: {
            NSAssert(AddressActionTypeReceive == self.actionType || AddressActionTypeExplore == self.actionType, @"Address explorer view controller won't support this action: %lu", self.actionType);
            break;
        }
    }
}

#pragma mark - Private Method
#pragma mark Request Logic
- (void)p_requestAddressSummary {
    if (self.requesting) {
        DLog(@"fetching");
        return;
    }
    
    [self requestDidStart];
    
    CBWRequest *request = [[CBWRequest alloc] init];
    // FIXME: 地址信息放在列表中批量获取，不需要重复获取，可以由用户主动触发
    // 获取地址信息
    [request addressSummaryWithAddressString:self.addressString completion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
        [self requestDidStop];
        
        // 保存地址信息
        [self.address updateWithDictionary:response];
        if (self.address.rid >= 0) {
            [self.address saveWithError:nil];
        }
        
        if (self.address.txCount > 0) {
            // 重置分页信息后获取交易
            self.page = 0;
            [self p_requestTransactions];
        }
    }];
}
- (void)p_requestTransactions {
    if (self.requesting) {
        DLog(@"fetching more? fetching");
        return;
    }
    
    [self requestDidStart];
    
    CBWRequest *request = [[CBWRequest alloc] init];
    
    [request addressTransactionsWithAddressString:self.addressString page:(self.page + 1) pagesize:10 completion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
        
        [self requestDidStop];
        
        if (!error) {
            // 分页
            NSUInteger totalCount = [[response objectForKey:CBWRequestResponseDataTotalCountKey] unsignedIntegerValue];
            NSUInteger pageSize = [[response objectForKey:CBWRequestResponseDataPageSizeKey] unsignedIntegerValue];
            self.page = [[response objectForKey:CBWRequestResponseDataPageKey] unsignedIntegerValue];
            self.isThereMoreDatas = totalCount > pageSize * self.page;
            
            DLog(@"fetched transactions page: %lu, page size: %lu, total: %lu", (unsigned long)self.page, (unsigned long)pageSize, (unsigned long)totalCount);
            
            // 解析交易
            [self.transactionStore insertTransactionsFromCollection:[response objectForKey:CBWRequestResponseDataListKey]];
        }
    }];
}

#pragma mark Handlers
- (void)p_handleBackToRoot {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)p_handleAmountChanged:(UITextField *)sender {
    if (sender) {
        NSMutableString *qrcodeString = [NSMutableString stringWithFormat:@"bitcoin:%@", self.address.address];
        NSMutableArray *parameters = [NSMutableArray array];
        if (self.address.label.length > 0) {
            [parameters addObject:[NSString stringWithFormat:@"label=%@", self.address.label]];
        }
        NSString *value = sender.text;
        if ([value BTC2SatoshiValue] > 0) {
            [parameters addObject:[NSString stringWithFormat:@"value=%@", value]];
        }
        if (parameters.count > 0) {
            [qrcodeString appendFormat:@"?%@", [parameters componentsJoinedByString:@"&"]];
        }
        self.headerView.qrcodeImageView.image = [qrcodeString qrcodeImageWithSize:self.headerView.qrcodeImageView.bounds.size];
    }
}

#pragma mark - UITableDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (AddressActionTypeExplore == self.actionType) ? [self.transactionStore numberOfSections] : 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (AddressActionTypeExplore == self.actionType) ? [self.transactionStore numberOfRowsInSection:section] : 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (AddressActionTypeReceive == self.actionType) {
        return nil;
    }
    
    NSDate *today = [NSDate date];
    NSString *day = [self.transactionStore dayInSection:section];
    if ([today isInSameDayWithDate:[NSDate dateFromString:day withFormat:@"yyyy-MM-dd"]]) {
        return NSLocalizedStringFromTable(@"Today", @"CBW", nil);
    }
    return day;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (AddressActionTypeReceive == self.actionType) {
        FormControlInputCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kAddressExplorerReceiveAmountCellIdentifier forIndexPath:indexPath];
        cell.inputType = FormControlInputTypeBitcoinAmount;
        cell.textField.placeholder = NSLocalizedStringFromTable(@"Placeholder receive_amount", @"CBW", nil);
        [cell.textField addTarget:self action:@selector(p_handleAmountChanged:) forControlEvents:UIControlEventEditingChanged];
        return cell;
    }
    
    CBWTransaction *transaction = [self.transactionStore transactionAtIndexPath:indexPath];
    if (!transaction) {
        DefaultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellDefaultIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"NaN";
        // return empty cell
        return cell;
    }
    transaction.latestBlockHeight = [BlockMonitor defaultMonitor].height;
    TransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseListViewCellTransactionIdentifier forIndexPath:indexPath];
    [cell setTransaction:transaction];
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
    if (AddressActionTypeExplore == self.actionType) {
        // goto transaction
        CBWTransaction *transaction = [self.transactionStore transactionAtIndexPath:indexPath];
        if (transaction) {
            TransactionViewController *transactionViewController = [[TransactionViewController alloc] initWithTransaction:transaction];
            [self.navigationController pushViewController:transactionViewController animated:YES];
        }
    }
}

#pragma mark <UIScrollViewDelegate>
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (AddressActionTypeExplore == self.actionType && !self.requesting && self.isThereMoreDatas) {
        CGFloat contentHeight = scrollView.contentSize.height;
        CGFloat offsetTop = targetContentOffset->y;
        CGFloat height = CGRectGetHeight(scrollView.frame);
        if (contentHeight - (offsetTop + height) < 2 * CBWCellHeightTransaction) {
            [self p_requestTransactions];
            [self.tableView reloadData];
        }
    }
}

#pragma mark - <CBWTransactionStoreDelegate>
- (void)transactionStoreWillUpdate:(CBWTransactionStore *)store {
}
- (void)transactionStoreDidUpdate:(CBWTransactionStore *)store {
    [self.tableView reloadData];
}
- (void)transactionStore:(CBWTransactionStore *)store didInsertSection:(NSString *)section atIndex:(NSUInteger)index {
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
}
- (void)transactionStore:(CBWTransactionStore *)store didUpdateRecord:(__kindof CBWRecordObject * _Nonnull)record atIndexPath:(NSIndexPath * _Nullable)indexPath forChangeType:(CBWTransactionStoreChangeType)changeType toNewIndexPath:(NSIndexPath * _Nullable)newIndexPath {
    if (changeType == CBWTransactionStoreChangeTypeInsert) {
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (changeType == CBWTransactionStoreChangeTypeUpdate) {
        if ([indexPath isEqual:newIndexPath]) {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
        }
    }
}

@end
