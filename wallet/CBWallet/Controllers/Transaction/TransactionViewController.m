//
//  TransactionViewController.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "TransactionViewController.h"
#import "AddressViewController.h"

#import "TransactionDataCell.h"
#import "TransactionIOCell.h"

#import "Database.h"
#import "CBWRequest.h"

#import "NSDate+Helper.h"

typedef NS_ENUM(NSUInteger, kTransactionViewControllerSection) {
    kTransactionViewControllerSectionSummary,
    kTransactionViewControllerSectionInputs,
    kTransactionViewControllerSectionOutputs,
    kTransactionViewControllerSectionBlock
};

static NSString *const kTransactionViewControllerCellIdentifierData = @"transaction.cell.data";
static NSString *const kTransactionViewControllerCellIdentifierIO = @"transaction.cell.io";

@interface TransactionViewController ()

@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSMutableArray *summaryTitles;
@property (nonatomic, strong) NSMutableArray *summaryDatas;
@property (nonatomic, strong) NSArray *blockTitles;
@property (nonatomic, strong) NSArray *blockDatas;

@property (nonatomic, strong) CBWTransaction *transactionDetail;

@end

@implementation TransactionViewController

- (instancetype)initWithTransaction:(CBWTransaction *)transaction {
    self = [self initWithTransactionHashId:transaction.hashID];
    if (self) {
        _transaction = transaction;
    }
    return self;
}

- (instancetype)initWithTransactionHashId:(NSString *)hashId {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _hashId = hashId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // navigation
    self.title = NSLocalizedStringFromTable(@"Navigation transaction", @"CBW", @"Transaction Detail");
    if (self.navigationController.viewControllers.count > 4) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(p_handleBackToRoot)];
    }
    
    
    // table view
    [self.tableView registerClass:[TransactionDataCell class] forCellReuseIdentifier:kTransactionViewControllerCellIdentifierData];
    [self.tableView registerClass:[TransactionIOCell class] forCellReuseIdentifier:kTransactionViewControllerCellIdentifierIO];
    
    if (!self.refreshControl) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(p_fetchTransactionDetails) forControlEvents:UIControlEventValueChanged];
    }
    
    // datas
    _sectionTitles = @[NSLocalizedStringFromTable(@"Transaction Section summary", @"CBW", nil),
                       NSLocalizedStringFromTable(@"Transaction Section inputs", @"CBW", nil),
                       NSLocalizedStringFromTable(@"Transaction Section outputs", @"CBW", nil),
                       NSLocalizedStringFromTable(@"Transaction Section block", @"CBW", nil)];
    
    _summaryTitles = [NSMutableArray arrayWithObject:NSLocalizedStringFromTable(@"Transaction Cell hash", @"CBW", nil)];
    _summaryDatas = [NSMutableArray arrayWithObject:self.hashId];
    if (self.transaction) {
        [_summaryTitles addObjectsFromArray:@[NSLocalizedStringFromTable(@"Transaction Cell value", @"CBW", nil),
                                                 NSLocalizedStringFromTable(@"Transaction Cell fee", @"CBW", nil),
                                                 NSLocalizedStringFromTable(@"Transaction Cell confirmations", @"CBW", nil)]];
        [_summaryDatas addObjectsFromArray:@[[@(self.transaction.value) satoshiBTCString],
                                             [@(self.transaction.fee) satoshiBTCString],
                                             [@(self.transaction.confirmations) groupingString]]];
    }
    
    _blockTitles = @[NSLocalizedStringFromTable(@"Transaction Cell time", @"CBW", nil),
                     NSLocalizedStringFromTable(@"Transaction Cell height", @"CBW", nil),
                     NSLocalizedStringFromTable(@"Transaction Cell size", @"CBW", nil)];
    
    
    // fetch
    [self p_fetchTransactionDetails];
    
    DLog(@"transaction view for address: %@", self.transaction.queryAddresses);
}

#pragma mark - Private Method

- (void)p_handleBackToRoot {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)p_fetchTransactionDetails {
    [self requestDidStart];
    CBWRequest *request = [CBWRequest request];
    [request transactionWithHash:self.hashId completion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
        [self requestDidStop];
        NSLog(@"transaction response: %@", response);
        if (!error) {
            // 填充数据
            BOOL initial = !self.transactionDetail;
            NSUInteger confirmations = self.transaction.confirmations;
            if (self.transactionDetail) {
                confirmations = self.transactionDetail.confirmations;
            }
            self.transactionDetail = [[CBWTransaction alloc] initWithDictionary:response];
            
            if (self.transactionDetail) {
                [self.tableView beginUpdates];
                if (initial) {
                    [self.summaryDatas removeObjectsInRange:NSMakeRange(1, self.summaryDatas.count - 1)];
                    [self.summaryTitles removeObjectsInRange:NSMakeRange(1, self.summaryDatas.count - 1)];
                    [self.summaryTitles addObjectsFromArray:@[NSLocalizedStringFromTable(@"Transaction Cell value", @"CBW", nil),
                                                              NSLocalizedStringFromTable(@"Transaction Cell fee", @"CBW", nil),
                                                              NSLocalizedStringFromTable(@"Transaction Cell confirmations", @"CBW", nil)]];
                    [self.summaryDatas addObjectsFromArray:@[[@(self.transaction.value) satoshiBTCString],
                                                             [@(self.transactionDetail.fee) satoshiBTCString],
                                                             [@(self.transactionDetail.confirmations) groupingString]]];
                    
                    NSString *dateFormat = @"yyyy-MM-dd HH:mm:ss";
                    NSString *blockTime = [self.transactionDetail.blockTime stringWithFormat:dateFormat];
                    if (!blockTime) {
                        blockTime = @"N/A";
                    }
                    NSString *blockHeight = @"N/A";
                    if (self.transactionDetail.blockHeight >= 0) {
                        blockHeight = [@(self.transactionDetail.blockHeight) groupingString];
                    }
                    self.blockDatas = @[blockTime,
                                        blockHeight,
                                        [NSString stringWithFormat:@"%@ Bytes", [@(self.transactionDetail.size) groupingString]]];
                    
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.numberOfSections)] withRowAnimation:UITableViewRowAnimationAutomatic];
                    
                } else if (self.transactionDetail.confirmations != confirmations) {
                    [self.summaryDatas setObject:@(self.transactionDetail.confirmations) atIndexedSubscript:3];
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    
                    if (!self.blockDatas) {
                        NSString *dateFormat = @"yyyy-MM-dd HH:mm:ss";
                        NSString *blockTime = [self.transactionDetail.blockTime stringWithFormat:dateFormat];
                        if (!blockTime) {
                            blockTime = @"N/A";
                        }
                        NSString *blockHeight = @"N/A";
                        if (self.transactionDetail.blockHeight >= 0) {
                            blockHeight = [@(self.transactionDetail.blockHeight) groupingString];
                        }
                        self.blockDatas = @[blockTime,
                                            blockHeight,
                                            [NSString stringWithFormat:@"%@ Bytes", [@(self.transactionDetail.size) groupingString]]];
                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:(self.tableView.numberOfSections - 1)] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                }
                
                
                [self.tableView endUpdates];
            }
        }
        
    }];
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 0;
    switch (section) {
        case kTransactionViewControllerSectionSummary: {
            number = self.summaryDatas.count;// hash[, value], fee, confirmations
            break;
        }
            
        case kTransactionViewControllerSectionInputs: {
            number = self.transactionDetail.inputsCount;
            break;
        }
            
        case kTransactionViewControllerSectionOutputs: {
            number = self.transactionDetail.outputsCount;
            break;
        }
            
        case kTransactionViewControllerSectionBlock: {
            number = self.blockDatas.count;// height, time, size
            break;
        }
    }
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.section == kTransactionViewControllerSectionInputs || indexPath.section == kTransactionViewControllerSectionOutputs) {
        // io
        cell = [tableView dequeueReusableCellWithIdentifier:kTransactionViewControllerCellIdentifierIO];
        cell.textLabel.textColor = [UIColor CBWPrimaryColor];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kTransactionViewControllerCellIdentifierData];
        ((TransactionDataCell *)cell).hashEnabled = NO;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.section) {
        case kTransactionViewControllerSectionSummary: {
            if (indexPath.row == 0) {
                ((TransactionDataCell *)cell).hashEnabled = YES;
            }
            cell.textLabel.text = self.summaryTitles[indexPath.row];
            cell.detailTextLabel.text = self.summaryDatas[indexPath.row];
            break;
        }
        case kTransactionViewControllerSectionInputs: {
            if (self.transactionDetail.isCoinbase && indexPath.row == 0) {
                cell.textLabel.text = @"Coinbase";
                cell.textLabel.textColor = [UIColor CBWTextColor];
                cell.detailTextLabel.text = @"";
            } else {
                InputItem *i = self.transactionDetail.inputs[indexPath.row];
                cell.textLabel.text = [i.prevAddresses componentsJoinedByString:@","];
                cell.detailTextLabel.text = [i.prevValue satoshiBTCString];
            }
            // 处理查询地址的显示
            if ([self.transaction.queryAddresses containsObject:cell.textLabel.text]) {
                cell.textLabel.textColor = [UIColor CBWSubTextColor];
            } else {
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
            break;
        }
        case kTransactionViewControllerSectionOutputs: {
            OutItem *o = self.transactionDetail.outputs[indexPath.row];
            cell.textLabel.text = [o.addresses componentsJoinedByString:@","];
            cell.detailTextLabel.text = [o.value satoshiBTCString];
            // 处理查询地址的显示
            if ([self.transaction.queryAddresses containsObject:cell.textLabel.text]) {
                cell.textLabel.textColor = [UIColor CBWSubTextColor];
            } else {
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
            break;
        }
        case kTransactionViewControllerSectionBlock: {
            cell.textLabel.text = self.blockTitles[indexPath.row];
            cell.detailTextLabel.text = self.blockDatas[indexPath.row];
            break;
        }
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionTitles objectAtIndex:section];
}

#pragma mark - <UITableViewDelegate>
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DefaultSectionHeaderView *headerView = (DefaultSectionHeaderView *)[super tableView:tableView viewForHeaderInSection:section];
    headerView.topHairlineHidden = YES;
    headerView.detailTextLabel.text = nil;
    if (section == kTransactionViewControllerSectionInputs) {
        headerView.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.transactionDetail.inputsCount];
    } else if (section == kTransactionViewControllerSectionOutputs) {
        headerView.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.transactionDetail.outputsCount];
    }
    return headerView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selecteAddress = nil;
    switch (indexPath.section) {
        case kTransactionViewControllerSectionInputs: {
            if (self.transaction.isCoinbase) {
                return;
            }
            InputItem *i = self.transactionDetail.inputs[indexPath.row];
            if (i.prevAddresses.count != 1) {
                return;
            }
            if ([self.transaction.queryAddresses containsObject:[i.prevAddresses firstObject]]) {
                return;
            }
            selecteAddress = [i.prevAddresses firstObject];
            break;
        }
        case kTransactionViewControllerSectionOutputs: {
            OutItem *o = self.transactionDetail.outputs[indexPath.row];
            if (o.addresses.count != 1) {
                return;
            }
            if ([self.transaction.queryAddresses containsObject:[o.addresses firstObject]]) {
                return;
            }
            selecteAddress = [o.addresses firstObject];
            break;
        }
    }
    if (selecteAddress) {
        CBWAddress *address = [[CBWAddress alloc] init];
        address.address = selecteAddress;
        AddressViewController *addressViewController = [[AddressViewController alloc] initWithAddress:address actionType:AddressActionTypeExplore];
        [self.navigationController pushViewController:addressViewController animated:YES];
    }
}

@end
