//
//  ProfileViewController.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "ProfileViewController.h"
#import "TransactionListViewController.h"
#import "SettingsViewController.h"

#import "CBWAccountStore.h"
#import "CBWBackup.h"
#import "CBWiCloud.h"
#import "NSDate+Helper.h"

typedef NS_ENUM(NSUInteger, kProfileSection) {
    kProfileSectionAccounts = 0,
//    kProfileSectionAllTransactions,
//    kProfileSectionSettings,
    kProfileSectionBackup
};

@interface ProfileViewController ()

@property (nonatomic, strong) NSArray *tableStrings;
@property (nonatomic, weak) UISwitch *iCloudSwitch;

@end

@implementation ProfileViewController

#pragma mark - Initialization

- (instancetype)initWithAccountStore:(CBWAccountStore *)store {
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
//                      @[NSLocalizedStringFromTable(@"Profile Cell all_transactions", @"CBW", @"All Transactions")],
//                      @[NSLocalizedStringFromTable(@"Profile Cell settings", @"CBW", @"Settings")],
                      @{NSLocalizedStringFromTable(@"Profile Section backup", @"CBW", nil):
                            @[
                                NSLocalizedStringFromTable(@"Profile Cell export", @"CBW", @"Export"),
                                NSLocalizedStringFromTable(@"Profile Cell iCloud", @"CBW", @"iCloud")
                                ]
                        }
                      ];
}

#pragma mark - Private Method
- (void)p_exportBackupImageToPhotoLibrary {
    CBWBackup *backup = [CBWBackup new];
    [backup saveToLocalPhotoLibraryWithCompleiton:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"export to photo library error: \n%@", error);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Error", @"CBW", nil) message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okay = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Okay", @"CBW", nil) style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:okay];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Success", @"CBW", nil) message:NSLocalizedStringFromTable(@"Alert Message saved_to_photo_library", @"CBW", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okay = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Okay", @"CBW", nil) style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:okay];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
    }];
}
- (void)p_handleToggleiCloudEnabled:(id)sender {
    DLog(@"toggle icloud");
    [CBWiCloud toggleiCloudBySwith:self.iCloudSwitch inViewController:self];
}

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
    DefaultSectionHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:BaseTableViewSectionHeaderIdentifier];
    view.topHairlineHidden = YES;
    return view;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellDefaultIdentifier forIndexPath:indexPath];
    cell.detailTextLabel.text = nil;
    cell.accessoryView = nil;
    
    if (indexPath.section == kProfileSectionAccounts) {
    
        CBWAccount *account = [self.accountStore recordAtIndex:indexPath.row];
        cell.textLabel.text = account.label;

    } else {

        // set text label
        id sectionStrings = self.tableStrings[indexPath.section];
        if ([sectionStrings isKindOfClass:[NSDictionary class]]) {
            id object = [[[sectionStrings allObjects] firstObject] objectAtIndex:indexPath.row];
            cell.textLabel.text = object;
        } else {
            cell.textLabel.text = [sectionStrings objectAtIndex:indexPath.row];
        }
        
        // set backup cells stuff
        if (indexPath.section == kProfileSectionBackup) {
            if (indexPath.row == 1) {
                // iCloud
                cell.detailTextLabel.text = [[[NSUserDefaults standardUserDefaults] objectForKey:CBWUserDefaultsiCloudSyncDateKey] stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
                if (!self.iCloudSwitch) {
                    UISwitch *aSwitch = [[UISwitch alloc] init];
                    [aSwitch addTarget:self action:@selector(p_handleToggleiCloudEnabled:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView = aSwitch;
                    self.iCloudSwitch = aSwitch;
                }
                self.iCloudSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:CBWUserDefaultsiCloudEnabledKey];
            }
        }
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
//        case kProfileSectionAllTransactions: {
//            TransactionListViewController *transactionListViewController = [[TransactionListViewController alloc] init];
//            [self.navigationController pushViewController:transactionListViewController animated:YES];
//            break;
//        }
//        case kProfileSectionSettings: {
//            SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
//            [self.navigationController pushViewController:settingsViewController animated:YES];
//            break;
//        }
            
        case kProfileSectionBackup: {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            if (indexPath.row == 0) {
                // export
                [self p_exportBackupImageToPhotoLibrary];
            } else if (indexPath.row == 1) {
                // icloud
                [self p_handleToggleiCloudEnabled:nil];
            }
            break;
        }
    }
}

@end
