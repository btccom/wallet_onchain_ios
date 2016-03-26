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

#import "AccountStore.h"

typedef NS_ENUM(NSUInteger, kProfileSection) {
    kProfileSectionAccounts = 0,
    kProfileSectionAllTransactions,
    kProfileSectionSettings,
    kProfileSectionBackup
};

@interface ProfileViewController ()

@property (nonatomic, strong) NSArray * _Nonnull tableStrings;

@end

@implementation ProfileViewController

#pragma mark - Initialization

- (instancetype)initWithAccountStore:(AccountStore *)store {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _accountStore = store;
    }
    return self;
}

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
    
    self.title = NSLocalizedStringFromTable(@"Navigation profile", @"CBW", @"Profile");
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_close"] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
    
    _tableStrings = @[@{NSLocalizedStringFromTable(@"Profile Section accounts", @"CBW", @"Accounts"): @[]},
                      @[NSLocalizedStringFromTable(@"Profile Cell all_transactions", @"CBW", @"All Transactions")],
                      @[NSLocalizedStringFromTable(@"Profile Cell settings", @"CBW", @"Settings")],
                      @{NSLocalizedStringFromTable(@"Profile Section backup", @"CBW", @"Sync"):
                            @[
                                NSLocalizedStringFromTable(@"Profile Cell export", @"CBW", @"Export"),
                                NSLocalizedStringFromTable(@"Profile Cell sync", @"CBW", @"Sync")
                                ]
                        }
                      ];
}

#pragma mark - Private Method
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableStrings.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kProfileSectionAccounts) {
        return self.accountStore.count;
    }
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
    if (indexPath.section == kProfileSectionAccounts) {
        Account *account = [self.accountStore recordAtIndex:indexPath.row];
        cell.textLabel.text = account.label;
        return cell;
    }
    
    id sectionStrings = self.tableStrings[indexPath.section];
    if ([sectionStrings isKindOfClass:[NSDictionary class]]) {
        id object = [[[sectionStrings allObjects] firstObject] objectAtIndex:indexPath.row];
        cell.textLabel.text = object;
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
                [self.delegate profileViewController:self didSelectAccount:[self.accountStore recordAtIndex:indexPath.row]];
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
