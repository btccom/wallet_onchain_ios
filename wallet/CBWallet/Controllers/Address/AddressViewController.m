//
//  AddressViewController.m
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AddressViewController.h"
#import "AddressHeaderView.h"
#import "TransactionViewController.h"
#import "AddressListViewController.h"

#import "Database.h"
#import "CBWRequest.h"

@interface AddressViewController ()<AddressHeaderViewDelegate>

@property (nonatomic, strong) TransactionStore *transactionStore;

@end

@implementation AddressViewController

- (TransactionStore *)transactionStore {
    if (!_transactionStore) {
        _transactionStore = [[TransactionStore alloc] initWithAddressString:self.address.address];
    }
    return _transactionStore;
}

#pragma mark - Initialization

- (instancetype)initWithAddress:(Address *)address actionType:(AddressActionType)actionType {
    self = [super initWithStyle:(actionType == AddressActionTypeDefault) ? UITableViewStylePlain : UITableViewStyleGrouped];
    if (self) {
        _address = address;
        _actionType = actionType;
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
            self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:self.address.archived ? @"navigation_unarchive" : @"navigation_archive"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleArchive:)],
                                                        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_share"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleShare:)]];
            addressHeaderView.labelEditable = YES;
            [self.transactionStore fetch];
            break;
        }
            
        case AddressActionTypeReceive: {
            self.title = NSLocalizedStringFromTable(@"Navigation receive", @"CBW", @"Receive");
            break;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self p_fetchTransactionsFromServerSide];
}

#pragma mark - Private Method
#pragma mark Request Logic
- (void)p_fetchTransactionsFromServerSide {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    CBWRequest *request = [[CBWRequest alloc] init];
    [request addressTransactionsWithAddressString:self.address.address limit:0 timestamp:0 completion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (!error) {
            DLog(@"request transactions \n%@", response);
        }
    }];
}

#pragma mark Handlers
- (void)p_handleShare:(id)sender {
    DLog(@"clicked share");
}

- (void)p_handleArchive:(id)sender {
    DLog(@"clicked archive");
    if (self.address.accountIdx == -1) {
        // TODO: 如果是 watched only address，则执行删除
        return;
    }
    self.address.archived = !self.address.archived;
    [self.address saveWithError:nil];
    
    // pop back
    if (((AddressStore *)self.address.store).isArchived) {
        // 检查是否为空
        if (self.address.store.count == 0) {
            // TODO: improve
            NSArray *viewControllers = self.navigationController.viewControllers;
            UIViewController *vc = [viewControllers objectAtIndex:(viewControllers.count - 3)];
            if ([vc isKindOfClass:[AddressListViewController class]]) {
                [((AddressListViewController *)vc) reload];
                [self.navigationController popToViewController:vc animated:YES];
                return;
            }
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.actionType == AddressActionTypeDefault) {
        return NSLocalizedStringFromTable(@"Address Section transactions", @"CBW", @"Transactions");
    }
    return nil;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.transactionStore.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Transaction *transaction = [self.transactionStore recordAtIndex:indexPath.row];
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

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CBWCellHeightTransaction;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.actionType == AddressActionTypeDefault) {
        // goto transaction
        Transaction *transaction = [self.transactionStore recordAtIndex:indexPath.row];
        if (transaction) {
            TransactionViewController *transactionViewController = [[TransactionViewController alloc] initWithTransaction:transaction];
            [self.navigationController pushViewController:transactionViewController animated:YES];
        }
    }
}

#pragma mark AddressHeaderViewDelegate
- (void)addressHeaderViewDidEndEditing:(AddressHeaderView *)view {
    DLog(@"address's label changed: %@", view.label);
}

@end
