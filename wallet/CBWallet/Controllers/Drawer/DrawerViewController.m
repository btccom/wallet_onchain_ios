//
//  DrawerViewController.m
//  CBWallet
//
//  Created by Zin on 16/7/14.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "DrawerViewController.h"

#import "DrawerSectionHeaderView.h"
#import "DrawerAccountTableViewCell.h"
#import "DrawerStaticTableViewCell.h"

#import "DrawerStaticCellModel.h"
#import "Database.h"
#import "BlockMonitor.h"

typedef NS_ENUM(NSUInteger, kDrawerSection) {
    kDrawerSectionAccountList,
    kDrawerSectionSettings,
    kDrawerSectionBlock
};

static NSString *const kDrawerSectionHeaderIdentifier = @"drawer.section.header";
static NSString *const kDrawerAccountCellIdentifier = @"drawer.cell.account";
static NSString *const kDrawerStaticCellIdentifier = @"drawer.cell.static";

@interface DrawerViewController ()

@property (nonatomic, strong) NSArray *datas;
/// CBWAccount or DrawerStaticCellModel
@property (nonatomic, strong) id selectedCellData;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) CBWAccountStore *accountStore;

@end

@implementation DrawerViewController

- (CBWAccountStore *)accountStore {
    if (!_accountStore) {
        _accountStore = [[CBWAccountStore alloc] init];
        [_accountStore fetch];
    }
    return _accountStore;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // init with account list section
    NSMutableArray *mutableDatas = [NSMutableArray arrayWithObject:@{NSLocalizedStringFromTable(@"Drawer Section accounts", @"CBW", nil): self.accountStore}];
    
    // settings
    DrawerStaticCellModel *manageWalletCellData = [DrawerStaticCellModel new];
    manageWalletCellData.iconName = @"drawer_wallet";
    manageWalletCellData.text = NSLocalizedStringFromTable(@"Drawer Cell manage_accounts", @"CBW", nil);
    DrawerStaticCellModel *settingsCellData = [DrawerStaticCellModel new];
    settingsCellData.iconName = @"drawer_settings";
    settingsCellData.text = NSLocalizedStringFromTable(@"Drawer Cell settings", @"CBW", nil);
    settingsCellData.detail = [NSString stringWithFormat:@"%@ (%@)", VERSION, BUNDLE_VERSION];
    [mutableDatas addObject:@[manageWalletCellData, settingsCellData]];
    
    // block
    DrawerStaticCellModel *blockCellData = [DrawerStaticCellModel new];
    blockCellData.iconName = @"drawer_block";
    blockCellData.text = NSLocalizedStringFromTable(@"Drawer Cell block_height", @"CBW", nil);
    blockCellData.detail = [@([BlockMonitor defaultMonitor].height) groupingString];
    [mutableDatas addObject:@[blockCellData]];
    
    _datas = [mutableDatas copy];
    
    self.tableView.separatorColor = [[UIColor CBWBlackColor] colorWithAlphaComponent:0.2];
    self.tableView.backgroundColor = [UIColor CBWDrawerBackgroundColor];
    [self.tableView registerClass:[DrawerSectionHeaderView class] forHeaderFooterViewReuseIdentifier:kDrawerSectionHeaderIdentifier];
    [self.tableView registerClass:[DrawerAccountTableViewCell class] forCellReuseIdentifier:kDrawerAccountCellIdentifier];
    [self.tableView registerClass:[DrawerStaticTableViewCell class] forCellReuseIdentifier:kDrawerStaticCellIdentifier];
}

#pragma mark - Handle Events

/// handle checking in
/// handle signing out
/// handle accounts updated
/// handle transactions updated

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section >= self.datas.count) {
        return 0;
    }
    id sectionData = [self.datas objectAtIndex:section];
    if ([sectionData isKindOfClass:[NSDictionary class]]) {
        if ([[[sectionData allValues] firstObject] isEqual:self.accountStore]) {
            return self.accountStore.count;
        }
    }
    if ([sectionData isKindOfClass:[NSArray class]]) {
        return [sectionData count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id sectionData = [self.datas objectAtIndex:indexPath.section];
    
    if ([sectionData isKindOfClass:[NSDictionary class]]) {
        if ([[[sectionData allValues] firstObject] isEqual:self.accountStore]) {
            CBWAccount *account = [self.accountStore recordAtIndex:indexPath.row];
            if (account) {
                DrawerAccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDrawerAccountCellIdentifier forIndexPath:indexPath];
                cell.textLabel.text = account.label;
                if (account.idx == CBWRecordWatchedIDX) {
                    cell.textLabel.text = NSLocalizedStringFromTable(@"Label watched_account", @"CBW", nil);
                    cell.detailTextLabel.text = NSLocalizedStringFromTable(@"Tip watched_account", @"CBW", nil);;
                    cell.balanceLabel.text = nil;
                } else {
                    cell.detailTextLabel.text = @"00 Txs";
                    cell.balanceLabel.text = [@1212000000 satoshiBTCString];
                }
                
                [cell becomeCurrent:[account isEqual:self.currentAccount] animated:NO];
                
                return cell;
            }
        }
    }
    if ([sectionData isKindOfClass:[NSArray class]]) {
        if (indexPath.row < [sectionData count]) {
            id cellData = [sectionData objectAtIndex:indexPath.row];
            if ([cellData isKindOfClass:[DrawerStaticCellModel class]]) {
                DrawerStaticCellModel *staticCellModel = (DrawerStaticCellModel *)cellData;
                DrawerStaticTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDrawerStaticCellIdentifier forIndexPath:indexPath];
                cell.imageView.image = [UIImage imageNamed:staticCellModel.iconName];
                cell.textLabel.text = staticCellModel.text;
                cell.detailTextLabel.text = staticCellModel.detail;
                return cell;
            }
        }
    }
    return [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellDefaultIdentifier];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id sectionData = [self.datas objectAtIndex:section];
    if ([sectionData isKindOfClass:[NSDictionary class]]) {
        return [[sectionData allKeys] firstObject];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id sectionData = [self.datas objectAtIndex:indexPath.section];
    if ([sectionData isKindOfClass:[NSDictionary class]]) {
        if ([[[sectionData allValues] firstObject] isEqual:self.accountStore]) {
            return CBWCellHeightDrawerAccount;
        }
    }
    
    return CBWCellHeightDefault;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DrawerSectionHeaderView *view = (DrawerSectionHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:kDrawerSectionHeaderIdentifier];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView titleForHeaderInSection:section]) {
        id sectionData = [self.datas objectAtIndex:section];
        if ([sectionData isKindOfClass:[NSDictionary class]]) {
            if ([[[sectionData allValues] firstObject] isEqual:self.accountStore]) {
                return 44;
            }
        }
        return CBWListSectionHeaderHeight;
    }
    return CBWLayoutInnerSpace;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[DrawerAccountTableViewCell class]]) {
        [(DrawerAccountTableViewCell *)cell becomeCurrent:YES animated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
