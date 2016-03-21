//
//  ProfileViewController.m
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "ProfileViewController.h"
#import "TransactionListViewController.h"
#import "SettingsViewController.h"

#import "Account.h"

typedef NS_ENUM(NSUInteger, kProfileSection) {
    kProfileSectionAccounts = 0,
    kProfileSectionAllTransactions,
    kProfileSectionSettings,
    kProfileSectionBackup
};

@interface ProfileViewController ()

@property (nonatomic, strong) NSArray * _Nonnull tableStrings;
@property (nonatomic, strong) NSMutableArray * _Nonnull accounts; // of Account

@end

@implementation ProfileViewController

- (NSMutableArray *)accounts {
    if (!_accounts) {
        _accounts = [[NSMutableArray alloc] initWithObjects:[Account watchedAccount], nil];
    }
    return _accounts;
}

#pragma mark - Initialization
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedStringFromTable(@"Navigation Profile", @"CBW", @"Profile");
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_close"] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
    
    _tableStrings = @[@{NSLocalizedStringFromTable(@"Profile Section Accounts", @"CBW", @"Accounts"): self.accounts},
                      @[NSLocalizedStringFromTable(@"Profile Cell AllTransactions", @"CBW", @"All Transactions")],
                      @[NSLocalizedStringFromTable(@"Profile Cell Settings", @"CBW", @"Settings")],
                      @{NSLocalizedStringFromTable(@"Profile Section Backup", @"CBW", @"Sync"):
                            @[
                                NSLocalizedStringFromTable(@"Profile Cell Export", @"CBW", @"Export"),
                                NSLocalizedStringFromTable(@"Profile Cell Sync", @"CBW", @"Sync")
                                ]
                        }
                      ];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // fake data
    [self.accounts removeAllObjects];
    for (NSInteger i = 0; i < 5; i++) {
        [self.accounts addObject:[Account new]];
    }
    [self.accounts addObject:[Account watchedAccount]];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Private Method
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableStrings.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id sectionStrings = self.tableStrings[section];
    if ([sectionStrings isKindOfClass:[NSDictionary class]]) {
        return [[[sectionStrings allObjects] firstObject] count];
    }
    return [sectionStrings count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id sectionStrings = self.tableStrings[section];
    if ([sectionStrings isKindOfClass:[NSDictionary class]]) {
        return [[sectionStrings allKeys] firstObject];
    }
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ListSectionHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:BaseListViewSectionHeaderIdentifier];
    view.topHairlineHidden = YES;
    return view;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DefaultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellDefaultIdentifier forIndexPath:indexPath];
    id sectionStrings = self.tableStrings[indexPath.section];
    if ([sectionStrings isKindOfClass:[NSDictionary class]]) {
        id object = [[[sectionStrings allObjects] firstObject] objectAtIndex:indexPath.row];
        if ([object isKindOfClass:[Account class]]) {
            cell.textLabel.text = [object label];
        } else {
            cell.textLabel.text = object;
        }
    } else {
        cell.textLabel.text = [sectionStrings objectAtIndex:indexPath.row];
    }
    return cell;
}
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case kProfileSectionAccounts: {
            if ([self.delegate respondsToSelector:@selector(profileViewController:didSelectAccount:)]) {
                [self.delegate profileViewController:self didSelectAccount:self.accounts[indexPath.row]];
            }
            break;
        }
        case kProfileSectionAllTransactions: {
            TransactionListViewController *transactionListViewController = [[TransactionListViewController alloc] init];
            [self.navigationController pushViewController:transactionListViewController animated:YES];
            break;
        }
        case kProfileSectionSettings: {
            SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
            [self.navigationController pushViewController:settingsViewController animated:YES];
            break;
        }
    }
}

@end
