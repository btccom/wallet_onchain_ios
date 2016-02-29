//
//  AddressViewController.m
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AddressViewController.h"
#import "AddressHeaderView.h"

#import "Address.h"
#import "Transaction.h"

@interface AddressViewController ()<AddressHeaderViewDelegate>

@property (nonatomic, strong) NSMutableArray * _Nullable transactions;

@end

@implementation AddressViewController

- (NSMutableArray *)transactions {
    if (!_transactions) {
        _transactions = [[NSMutableArray alloc] init];
    }
    return _transactions;
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
            self.title = NSLocalizedStringFromTable(@"Navigation Address", @"CBW", @"Address");
            self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_archive"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleArchive:)],
                                                        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_share"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleShare:)]];
            addressHeaderView.labelEditable = YES;
            [self p_fetchTransactions];
            break;
        }
            
        case AddressActionTypeReceive: {
            self.title = NSLocalizedStringFromTable(@"Navigation Receive", @"CBW", @"Receive");
            break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
#pragma mark Handlers
- (void)p_handleShare:(id)sender {
    NSLog(@"clicked share");
}

- (void)p_handleArchive:(id)sender {
    NSLog(@"clicked archive");
}

#pragma mark -
- (void)p_fetchTransactions {
    [self.transactions removeAllObjects];
    for (NSInteger i = 0; i < 20; i++) {
        Transaction *transaction = [Transaction new];
        [self.transactions addObject:transaction];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UITableDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.actionType == AddressActionTypeDefault) {
        return NSLocalizedStringFromTable(@"Address Section Transactions", @"CBW", @"Transactions");
    }
    return nil;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.transactions.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Transaction *transaction = self.transactions[indexPath.row];
    if (!transaction) {
        DefaultCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellDefaultIdentifier forIndexPath:indexPath];
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

#pragma mark AddressHeaderViewDelegate
- (void)addressHeaderViewDidEndEditing:(AddressHeaderView *)view {
    NSLog(@"address's label changed: %@", view.label);
}

@end
