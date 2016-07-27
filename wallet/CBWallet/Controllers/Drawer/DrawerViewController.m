//
//  DrawerViewController.m
//  CBWallet
//
//  Created by Zin on 16/7/14.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "DrawerViewController.h"

#import "SWRevealViewController.h"
#import "AccountViewController.h"
#import "AccountsManagerViewController.h"
#import "SettingsViewController.h"
#import "BlankViewController.h"

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

@property (nonatomic, strong) CBWAccountStore *accountStore;

@property (nonatomic, strong) NSArray *datas;
/// CBWAccount or DrawerStaticCellModel, weak
@property (nonatomic, weak) id selectedCellData;
/// strong
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
/// weak
@property (nonatomic, weak) DrawerStaticCellModel *blockHeightCellModel;
/// strong
@property (nonatomic, strong) NSIndexPath *blockHeightIndexPath;

@end

@implementation DrawerViewController

- (CBWAccountStore *)accountStore {
    if (!_accountStore) {
        _accountStore = [[CBWAccountStore alloc] init];
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
    
    // block monitor
    [[BlockMonitor defaultMonitor] begin];
    
    // init with account list section
    NSMutableArray *mutableDatas = [NSMutableArray arrayWithObject:@{NSLocalizedStringFromTable(@"Drawer Section accounts", @"CBW", nil): self.accountStore}];
    
    // settings section
    DrawerStaticCellModel *manageWalletCellData = [DrawerStaticCellModel new];
    manageWalletCellData.iconName = @"drawer_wallet";
    manageWalletCellData.text = NSLocalizedStringFromTable(@"Drawer Cell manage_accounts", @"CBW", nil);
    manageWalletCellData.controllerClassName = @"AccountsManagerViewController";
    DrawerStaticCellModel *settingsCellData = [DrawerStaticCellModel new];
    settingsCellData.iconName = @"drawer_settings";
    settingsCellData.text = NSLocalizedStringFromTable(@"Drawer Cell settings", @"CBW", nil);
    settingsCellData.detail = [NSString stringWithFormat:@"%@ (%@)", VERSION, BUNDLE_VERSION];
    settingsCellData.controllerClassName = @"SettingsViewController";
    [mutableDatas addObject:@[manageWalletCellData, settingsCellData]];
    
    // block section
    DrawerStaticCellModel *blockCellData = [DrawerStaticCellModel new];
    blockCellData.iconName = @"drawer_block";
    blockCellData.text = NSLocalizedStringFromTable(@"Drawer Cell block_height", @"CBW", nil);
    blockCellData.detail = [@([BlockMonitor defaultMonitor].height) groupingString];
    [mutableDatas addObject:@[blockCellData]];
    _blockHeightCellModel = blockCellData;
    
    _datas = [mutableDatas copy];
    
    // table
    self.tableView.separatorColor = [[UIColor CBWBlackColor] colorWithAlphaComponent:0.2];
    self.tableView.backgroundColor = [UIColor CBWDrawerBackgroundColor];
    [self.tableView registerClass:[DrawerSectionHeaderView class] forHeaderFooterViewReuseIdentifier:kDrawerSectionHeaderIdentifier];
    [self.tableView registerClass:[DrawerAccountTableViewCell class] forCellReuseIdentifier:kDrawerAccountCellIdentifier];
    [self.tableView registerClass:[DrawerStaticTableViewCell class] forCellReuseIdentifier:kDrawerStaticCellIdentifier];
    
    // notifications
    [self p_registerNotifications];
}

#pragma mark - Private Method

- (void)p_registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_handleNotification:) name:CBWNotificationCheckedIn object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_handleNotification:) name:CBWNotificationCheckedOut object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_handleNotification:) name:CBWNotificationWalletCreated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_handleNotification:) name:CBWNotificationWalletRecovered object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_handleNotification:) name:CBWNotificationSignedOut object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_handleNotification:) name:CBWNotificationTransactionCreated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_handleNotification:) name:CBWNotificationAccountCreated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_handleNotification:) name:CBWNotificationAccountUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_handleNotification:) name:BlockMonitorNotificationNewBlock object:nil];
}

- (void)p_handleNotification:(NSNotification *)notification {
    DLog(@"notification: %@", notification);
    if ([notification.name isEqualToString:CBWNotificationCheckedIn]) {
        // TODO: 区分 launch 时的 check in
        [self p_handleSignIn];
    } else if ([notification.name isEqualToString:CBWNotificationWalletCreated]) {
        [self p_handleSignIn];
    } else if ([notification.name isEqualToString:CBWNotificationWalletRecovered]) {
        [self p_handleSignIn];
    } else if ([notification.name isEqualToString:CBWNotificationTransactionCreated]) {
        [self p_reload];
    } else if ([notification.name isEqualToString:CBWNotificationAccountCreated]) {
        [self p_reload];
    } else if ([notification.name isEqualToString:CBWNotificationAccountUpdated]) {
        [self p_reload];
    } else if ([notification.name isEqualToString:CBWNotificationSignedOut]) {
        [self p_handleSignOut];
    } else if ([notification.name isEqualToString:BlockMonitorNotificationNewBlock]) {
        DLog(@"new block height: %lu", (unsigned long)[BlockMonitor defaultMonitor].height);
        
        self.blockHeightCellModel.detail = [@([BlockMonitor defaultMonitor].height) groupingString];
        // update block height cell
        [self.tableView reloadRowsAtIndexPaths:@[self.blockHeightIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)p_reload {
    [self.tableView reloadData];
}

- (void)p_handleSignIn {
    if (!self.selectedIndexPath) {
        [self.accountStore fetch];
        
        // select one account
        CBWAccount *account = [self.accountStore recordAtIndex:0];
        if (account) {
            SWRevealViewController *revealViewController = [self revealViewController];
            AccountViewController *accountViewController = [[AccountViewController alloc] initWithAccount:account];
            [revealViewController setFrontViewController:[[UINavigationController alloc] initWithRootViewController:accountViewController]];
            [revealViewController setFrontViewPosition:FrontViewPositionLeft];
            _selectedCellData = account;
            _selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        }
    }
    
    [self p_reload];
}

- (void)p_handleSignOut {
    DLog(@"------- ------- ------- ------- ------- ------- ------- \nsign out \n------- ------- ------- ------- ------- ------- -------");
    [self.accountStore flush];
    [self.tableView reloadData];
    _selectedIndexPath = nil;
    [[self revealViewController] setFrontViewController:[BlankViewController new]];
    [[self revealViewController] setFrontViewPosition:FrontViewPositionRight];
}

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
        if ([[[sectionData allValues] firstObject] isKindOfClass:[CBWAccountStore class]]) {
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
        if ([[[sectionData allValues] firstObject] isKindOfClass:[CBWAccountStore class]]) {
            CBWAccount *account = [self.accountStore recordAtIndex:indexPath.row];
            if (account) {
                DrawerAccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDrawerAccountCellIdentifier forIndexPath:indexPath];
                cell.textLabel.text = account.label;
                if (account.idx == CBWRecordWatchedIDX) {
                    cell.textLabel.text = NSLocalizedStringFromTable(@"Label watched_account", @"CBW", nil);
                    cell.detailTextLabel.text = NSLocalizedStringFromTable(@"Tip watched_account", @"CBW", nil);;
                    cell.balanceLabel.text = nil;
                } else {
                    NSDictionary *analyzeData = [account analyze];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ Txs", [@([[analyzeData objectForKey:CBWAccountTotalTXCountKey] integerValue]) groupingString]];
                    cell.balanceLabel.text = [@([[analyzeData objectForKey:CBWAccountTotalBalanceKey] longLongValue]) satoshiBTCString];
                }
                
                [cell becomeCurrent:[indexPath isEqual:self.selectedIndexPath] animated:NO];
                
                return cell;
            }
        }
    }
    if ([sectionData isKindOfClass:[NSArray class]]) {
        if (indexPath.row < [sectionData count]) {
            id cellData = [sectionData objectAtIndex:indexPath.row];
            if ([cellData isKindOfClass:[DrawerStaticCellModel class]]) {
                
                if ([cellData isEqual:self.blockHeightCellModel]) {
                    self.blockHeightIndexPath = indexPath;
                }
                
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
        if ([[[sectionData allValues] firstObject] isKindOfClass:[CBWAccountStore class]]) {
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
            if ([[[sectionData allValues] firstObject] isKindOfClass:[CBWAccountStore class]]) {
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([indexPath isEqual:self.blockHeightIndexPath]) {
        return;
    }
    
    if ([_selectedIndexPath isEqual:indexPath]) {
        [[self revealViewController] setFrontViewPosition:FrontViewPositionLeft animated:YES];
        return;
    }
    
    id sectionData = [self.datas objectAtIndex:indexPath.section];
    
    if ([sectionData isKindOfClass:[NSDictionary class]]) {
        if ([[[sectionData allValues] firstObject] isKindOfClass:[CBWAccountStore class]]) {
            CBWAccount *account = [self.accountStore recordAtIndex:indexPath.row];
            _selectedCellData = account;
            if (account) {
                AccountViewController *accountViewController = [[AccountViewController alloc] initWithAccount:account];
                [[self revealViewController] setFrontViewController:[[UINavigationController alloc] initWithRootViewController:accountViewController]];
            }
        }
    }
    
    if ([sectionData isKindOfClass:[NSArray class]]) {
        if (indexPath.row < [sectionData count]) {
            id cellData = [sectionData objectAtIndex:indexPath.row];
            _selectedCellData = cellData;
            if ([cellData isKindOfClass:[DrawerStaticCellModel class]]) {
                NSString *className = ((DrawerStaticCellModel *)cellData).controllerClassName;
                if (className) {
                    Class class = NSClassFromString(className);
                    if (class) {
                        UIViewController *viewController = [[class alloc] init];
                        if (viewController) {
                            if ([viewController isKindOfClass:[AccountsManagerViewController class]]) {
                                ((AccountsManagerViewController *)viewController).accountStore = self.accountStore;
                            }
                            
                            [[self revealViewController] setFrontViewController:[[UINavigationController alloc] initWithRootViewController:viewController]];
                        }
                    }
                }
            }
        }
    }
    
    
    
    // handle cell
    DrawerTableViewCell *selectedCell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [selectedCell becomeCurrent:NO animated:YES];
    DrawerTableViewCell *currenctCell = [tableView cellForRowAtIndexPath:indexPath];
    [currenctCell becomeCurrent:YES animated:YES];
    
    // toggle
    [[self revealViewController] revealToggleAnimated:YES];
    
    //
    _selectedIndexPath = indexPath;
}

@end
