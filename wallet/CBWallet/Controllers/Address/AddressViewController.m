//
//  AddressViewController.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AddressViewController.h"
#import "AddressHeaderView.h"
#import "TransactionViewController.h"
#import "AddressListViewController.h"

#import "Database.h"
#import "CBWRequest.h"

@interface AddressViewController ()<AddressHeaderViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) CBWTransactionStore *transactionStore;
@property (nonatomic, assign) BOOL isThereMoreDatas;
@property (nonatomic, assign) NSUInteger page;

@end

@implementation AddressViewController

- (CBWTransactionStore *)transactionStore {
    if (!_transactionStore) {
        _transactionStore = [[CBWTransactionStore alloc] initWithAddressString:self.address.address];
    }
    return _transactionStore;
}

#pragma mark - Initialization

- (instancetype)initWithAddress:(CBWAddress *)address actionType:(AddressActionType)actionType {
    self = [super initWithStyle:(actionType == AddressActionTypeDefault) ? UITableViewStylePlain : UITableViewStyleGrouped];
    if (self) {
        _address = address;
        _actionType = actionType;
        _page = 0;
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
    [addressHeaderView setAddress:self.address.address withLabel:self.address.label];
    addressHeaderView.delegate = self;
    [self.tableView setTableHeaderView:addressHeaderView];
    switch (self.actionType) {
        case AddressActionTypeDefault: {
            self.title = NSLocalizedStringFromTable(@"Navigation address", @"CBW", @"Address");
//            NSString *archiveItemImageName = @"navigation_trash";
//            if (self.address.accountIdx != CBWRecordWatchedIdx) {
//                archiveItemImageName = self.address.archived ? @"navigation_unarchive" : @"navigation_archive";
//            }
//            UIImage *archiveItemImage = [UIImage imageNamed:archiveItemImageName];
//            UIBarButtonItem *archiveItem = [[UIBarButtonItem alloc] initWithImage:archiveItemImage style:UIBarButtonItemStylePlain target:self action:@selector(p_handleArchive:)];
//            UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_share"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleShare:)];
//            self.navigationItem.rightBarButtonItems = @[archiveItem
                                                        //,shareItem];
//                                                        ];
            addressHeaderView.labelEditable = YES;
            
            [self.transactionStore fetch];
            [self.tableView reloadData];
            
            // 请求摘要及交易信息
            [self p_requestAddressSummary];
            
            break;
        }
            
        case AddressActionTypeReceive: {
            self.title = NSLocalizedStringFromTable(@"Navigation receive", @"CBW", @"Receive");
            break;
        }
            
        case AddressActionTypeSend:
        case AddressActionTypeChange:
            // won't reach here
            break;
            
        case AddressActionTypeExplore: {
            self.title = NSLocalizedStringFromTable(@"Navigation address", @"CBW", @"Address");
//            addressHeaderView.labelEditable = NO;
            
            [self.transactionStore fetch];
            [self.tableView reloadData];
            
            // 请求摘要及交易信息
            [self p_requestAddressSummary];
            break;
        }
        case AddressActionTypeCreate: {
            self.title = NSLocalizedStringFromTable(@"Navigation create_address", @"CBW", nil);
            addressHeaderView.labelEditable = YES;
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(p_handleSaveNewAddress:)];
            break;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.actionType == AddressActionTypeCreate) {
        // 删除
        [self.address deleteFromStore];
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
    [request addressSummaryWithAddressString:self.address.address completion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
        [self requestDidStop];
        // 保存地址信息
        [self.address updateWithDictionary:response];
        if (self.address.rid >= 0) {
            [self.address saveWithError:nil];
        }
        if (self.address.txCount > 0) {
            // 重置分页信息后获取交易
            self.page = 0;
            [self.transactionStore flush];
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
    
    [request addressTransactionsWithAddressString:self.address.address page:(self.page + 1) pagesize:10 completion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
        
        [self requestDidStop];
        
        if (!error) {
            // 分页
            NSUInteger totalCount = [[response objectForKey:CBWRequestResponseDataTotalCountKey] unsignedIntegerValue];
            NSUInteger pageSize = [[response objectForKey:CBWRequestResponseDataPageSizeKey] unsignedIntegerValue];
            self.page = [[response objectForKey:CBWRequestResponseDataPageKey] unsignedIntegerValue];
            self.isThereMoreDatas = totalCount > pageSize * self.page;
            
            DLog(@"fetched transactions page: %lu, page size: %lu, total: %lu", (unsigned long)self.page, (unsigned long)pageSize, (unsigned long)totalCount);
            
            // 解析交易
            [self.transactionStore addTransactionsFromJsonObject:[response objectForKey:CBWRequestResponseDataListKey] isCacheNeeded:(self.page == 1)];
//            [self.transactionStore sort];
            
            // 更新界面
            [self.tableView reloadData];
//            if ([self.tableView numberOfSections] == 0) {
//                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
//            } else {
//                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
//            }
        }
    }];
}

#pragma mark Handlers
- (void)p_handleSaveNewAddress:(id)sender {
    [self reportActivity:@"saveNewAddress"];
    
    [self.view endEditing:YES];
    
    [self.address saveWithError:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
//    // 设置
//    self.actionType = AddressActionTypeDefault;
//    // 移除按钮
//    self.navigationItem.rightBarButtonItem = nil;
//    // 加载交易
//    [self.transactionStore fetch];
//    [self.tableView reloadData];
//    [self p_requestAddressSummary];
}

- (void)p_handleShare:(id)sender {
    DLog(@"clicked share");
}

- (void)p_handleArchive:(id)sender {
    DLog(@"clicked archive, %ld, %ld", (long)self.address.accountIDX, (long)self.address.idx);
    if (self.address.accountIDX == CBWRecordWatchedIDX) {
        DLog(@"to delete watched address");
        [self.address deleteWatchedAddressFromStore:self.address.store];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    self.address.archived = !self.address.archived;
    [self.address saveWithError:nil];
    
    // pop back
    if (((CBWAddressStore *)self.address.store).isArchived) {
        // 检查是否为空
        if (self.address.store.count == 0) {
            // TODO: improve
            NSArray *viewControllers = self.navigationController.viewControllers;
            UIViewController *vc = [viewControllers objectAtIndex:(viewControllers.count - 3)];
            if ([vc isKindOfClass:[AddressListViewController class]]) {
//                [((AddressListViewController *)vc) reload];
                [self.navigationController popToViewController:vc animated:YES];
                return;
            }
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.actionType == AddressActionTypeDefault || self.actionType == AddressActionTypeExplore) {
        return NSLocalizedStringFromTable(@"Address Section transactions", @"CBW", @"Transactions");
    }
    return nil;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.transactionStore.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CBWTransaction *transaction = [self.transactionStore recordAtIndex:indexPath.row];
    if (!transaction) {
        DefaultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellDefaultIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"NaN";
        // return empty cell
        return cell;
    }
    TransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseListViewCellTransactionIdentifier forIndexPath:indexPath];
    [cell setTransaction:transaction];
    return cell;
}

#pragma mark <UITableViewDelegate>
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DefaultSectionHeaderView *headerView = (DefaultSectionHeaderView *)[super tableView:tableView viewForHeaderInSection:section];
    headerView.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d txs", @"CBW", nil), self.address.txCount];
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CBWCellHeightTransaction;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.actionType == AddressActionTypeDefault || self.actionType == AddressActionTypeExplore) {
        // goto transaction
        CBWTransaction *transaction = [self.transactionStore recordAtIndex:indexPath.row];
        transaction.queryAddress = self.address.address;
//        CBWTransaction *transaction = [self.transactionStore transactionAtIndexPath:indexPath];
        if (transaction) {
            TransactionViewController *transactionViewController = [[TransactionViewController alloc] initWithTransaction:transaction];
            [self.navigationController pushViewController:transactionViewController animated:YES];
        }
    }
}

#pragma mark <AddressHeaderViewDelegate>
- (void)addressHeaderViewDidEndEditing:(AddressHeaderView *)view {
    [self reportActivity:@"addressLabelChanged"];
    
    DLog(@"address's label changed: %@", view.label);
    
    if (self.actionType != AddressActionTypeCreate) {// 新建地址不会自动保存
        [self.address saveWithError:nil];
    }
}
- (void)addressHeaderViewDidEditingChanged:(AddressHeaderView *)view {
    self.address.label = view.label;
}

#pragma mark <UIScrollViewDelegate>
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (!self.requesting) {
        if (self.isThereMoreDatas) {
            CGFloat contentHeight = scrollView.contentSize.height;
            CGFloat offsetTop = targetContentOffset->y;
            CGFloat height = CGRectGetHeight(scrollView.frame);
            if (contentHeight - (offsetTop + height) < 200.f) {
                [self p_requestTransactions];
            }
        }
    }
}

@end
