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
@property (nonatomic, strong) NSArray *summaryTitles;
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
    
    self.title = NSLocalizedStringFromTable(@"Navigation transaction", @"CBW", @"Transaction Detail");
    [self.tableView registerClass:[TransactionDataCell class] forCellReuseIdentifier:kTransactionViewControllerCellIdentifierData];
    [self.tableView registerClass:[TransactionIOCell class] forCellReuseIdentifier:kTransactionViewControllerCellIdentifierIO];
    
    _sectionTitles = @[NSLocalizedStringFromTable(@"Transaction Section summary", @"CBW", nil),
                       NSLocalizedStringFromTable(@"Transaction Section inputs", @"CBW", nil),
                       NSLocalizedStringFromTable(@"Transaction Section outputs", @"CBW", nil),
                       NSLocalizedStringFromTable(@"Transaction Section block", @"CBW", nil)];
    
    NSMutableArray *baseSummaryTitles = [@[NSLocalizedStringFromTable(@"Transaction Cell hash", @"CBW", nil),
                                           NSLocalizedStringFromTable(@"Transaction Cell fee", @"CBW", nil),
                                           NSLocalizedStringFromTable(@"Transaction Cell confirmations", @"CBW", nil)] mutableCopy];
    _summaryDatas = [NSMutableArray arrayWithObject:self.hashId];
    if (self.transaction) {
        [baseSummaryTitles insertObject:NSLocalizedStringFromTable(@"Transaction Cell value", @"CBW", nil) atIndex:1];
        [_summaryDatas addObject:[@(self.transaction.value) satoshiBTCString]];
    }
    _summaryTitles = [baseSummaryTitles copy];
    
    _blockTitles = @[NSLocalizedStringFromTable(@"Transaction Cell time", @"CBW", nil),
                     NSLocalizedStringFromTable(@"Transaction Cell height", @"CBW", nil),
                     NSLocalizedStringFromTable(@"Transaction Cell size", @"CBW", nil)];
    
    
    [self requestDidStart];
    CBWRequest *request = [CBWRequest request];
    [request transactionWithHash:self.hashId completion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
        [self requestDidStop];
        NSLog(@"transaction response: %@", response);
        if (!error) {
            // 填充数据
            self.transactionDetail = [[CBWTransaction alloc] initWithDictionary:response];
            
            if (self.transactionDetail) {
                [self.summaryDatas addObject:[@(self.transactionDetail.fee) satoshiBTCString]];
                [self.summaryDatas addObject:[NSString stringWithFormat:@"%lu", (unsigned long)self.transactionDetail.confirmations]];
                
                NSString *blockTime = [self.transactionDetail.blockTime stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
                if (!blockTime) {
                    blockTime = @"";
                }
                self.blockDatas = @[blockTime,
                                    [NSString stringWithFormat:@"%lu", (unsigned long)self.transactionDetail.blockHeight],
                                    [NSString stringWithFormat:@"%lu", (unsigned long)self.transactionDetail.size]];
                
                // 刷新表格
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.numberOfSections)] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
        
    }];
    
    DLog(@"transaction view for address: %@", self.transaction.queryAddress);
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
            if ([cell.textLabel.text isEqualToString:self.transaction.queryAddress]) {
                cell.textLabel.textColor = [UIColor CBWSubTextColor];
            }
            break;
        }
        case kTransactionViewControllerSectionOutputs: {
            OutItem *o = self.transactionDetail.outputs[indexPath.row];
            cell.textLabel.text = [o.addresses componentsJoinedByString:@","];
            cell.detailTextLabel.text = [o.value satoshiBTCString];
            // 处理查询地址的显示
            if ([cell.textLabel.text isEqualToString:self.transaction.queryAddress]) {
                cell.textLabel.textColor = [UIColor CBWSubTextColor];
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
            if ([[i.prevAddresses firstObject] isEqualToString:self.transaction.queryAddress]) {
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
            if ([[o.addresses firstObject] isEqualToString:self.transaction.queryAddress]) {
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
