//
//  ProfileViewController.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "ProfileViewController.h"
#import "TransactionListViewController.h"
#import "AccountsManagerViewController.h"
#import "SettingsViewController.h"
#import "PasswordViewController.h"

#import "CBWAccountStore.h"
#import "CBWBackup.h"
#import "Guard.h"

#import "SSKeychain.h"

#import "NSDate+Helper.h"

@import LocalAuthentication;

typedef NS_ENUM(NSUInteger, kProfileSection) {
    kProfileSectionAccounts = 0,
//    kProfileSectionAllTransactions,
//    kProfileSectionSettings,
    kProfileSectionSecurity,
    kProfileSectionBackup,
    kProfileSectionSignOut
};

@interface ProfileViewController ()

@property (nonatomic, strong) NSArray *tableStrings;
@property (nonatomic, strong) UISwitch *iCloudSwitch;
@property (nonatomic, strong) UISwitch *touchIDSwitch;

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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Navigation manage_accounts", @"CBW", nil) style:UIBarButtonItemStylePlain target:self action:@selector(p_handleManageAccounts:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];//[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_close"] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
    
    NSMutableArray *securityCells = [NSMutableArray arrayWithObjects:
                                     NSLocalizedStringFromTable(@"Profile Cell change_password", @"CBW", @"Settings"),
                                     NSLocalizedStringFromTable(@"Profile Cell change_hint", @"CBW", @"Chnage Hint"),
                                     nil];
    NSError *error = nil;
    LAContext *laContext = [[LAContext alloc] init];
    if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [securityCells addObject:NSLocalizedStringFromTable(@"Profile Cell touchid", @"CBW", nil)];
    }
    
    _tableStrings = @[@{NSLocalizedStringFromTable(@"Profile Section accounts", @"CBW", @"Accounts"): @[]},
                      @{NSLocalizedStringFromTable(@"Profile Section security", @"CBW", nil): securityCells},
                      @{NSLocalizedStringFromTable(@"Profile Section backup", @"CBW", nil): @[
                            NSLocalizedStringFromTable(@"Profile Cell export", @"CBW", @"Export"),
                            NSLocalizedStringFromTable(@"Profile Cell iCloud", @"CBW", @"iCloud")]},
                      @[NSLocalizedStringFromTable(@"Profile Cell sign_out", @"CBW", nil)]
                      ];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // account store could be updated
    [self.tableView reloadData];
}

#pragma mark - Private Method
- (void)p_exportBackupImageToPhotoLibraryWithCell:(UITableViewCell *)cell {
    [CBWBackup saveToLocalPhotoLibraryWithCompleiton:^(NSURL *assetURL, NSError *error) {
        id indicator = cell.accessoryView;
        if ([indicator isKindOfClass:[UIActivityIndicatorView class]]) {
            [indicator stopAnimating];
        }
        if (error) {
            NSLog(@"export to photo library error: \n%@", error);
            [self alertMessage:error.localizedDescription withTitle:NSLocalizedStringFromTable(@"Error", @"CBW", nil)];
        } else {
            [self alertMessage:NSLocalizedStringFromTable(@"Alert Message saved_to_photo_library", @"CBW", nil) withTitle:NSLocalizedStringFromTable(@"Success", @"CBW", nil)];
        }
    }];
}
#pragma mark Handlers
- (void)p_handleManageAccounts:(id)sender {
    AccountsManagerViewController *managerViewController = [[AccountsManagerViewController alloc] initWithAccountStore:self.accountStore];
    [self.navigationController pushViewController:managerViewController animated:YES];
}
- (void)p_handleToggleiCloudEnabled:(id)sender {
    DLog(@"toggle icloud");
    [CBWBackup toggleiCloudBySwith:self.iCloudSwitch inViewController:self];
}
- (void)p_handleToggleTouchIdEnabled:(id)sender {
    DLog(@"toggle touch id");
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CBWUserDefaultsTouchIdEnabledKey]) {
        // turn off
        if ([SSKeychain deletePasswordForService:CBWKeychainMasterPasswordService account:CBWKeychainAccountDefault]) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:CBWUserDefaultsTouchIdEnabledKey];
            if ([[NSUserDefaults standardUserDefaults] synchronize]) {
                [self.touchIDSwitch setOn:NO animated:YES];
            }
        }
        return;
    }
    
    // TODO: validate domain status
    // turn on
    LAContext *context = [LAContext new];
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"Alert Message enable_touchid", nil) reply:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    // authorized
                    if ([SSKeychain setPassword:[Guard globalGuard].code forService:CBWKeychainMasterPasswordService account:CBWKeychainAccountDefault]) {
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CBWUserDefaultsTouchIdEnabledKey];
                        if ([[NSUserDefaults standardUserDefaults] synchronize]) {
                            [self.touchIDSwitch setOn:YES animated:YES];
                        } else {
                            [self.touchIDSwitch setOn:NO animated:YES];
                        }
                    }
                } else if (error) {
                    [self.touchIDSwitch setOn:NO animated:YES];
                    NSString *message = nil;
                    switch (error.code) {
                        case LAErrorAuthenticationFailed: {
                            message = NSLocalizedString(@"There was a problem verifying your identity.", nil);
                            break;
                        }
                            
                        case LAErrorUserCancel: {
//                            message = NSLocalizedString(@"You canceled.", nil);
                            break;
                        }
                            
                        case LAErrorUserFallback: {
//                            message = NSLocalizedString(@"You pressed password.", nil);
                            break;
                        }
                            
                        default:
                            message = NSLocalizedString(@"Touch ID may not be configured.", nil);
                            break;
                    }
                    if (message) {
                        [self alertMessage:message withTitle:NSLocalizedString(@"Error", nil)];
                    }
                }
            });
        }];
    }
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
    cell.textLabel.textColor = [UIColor CBWTextColor];
    
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
        
        // set touch id cell stuff
        if (indexPath.section == kProfileSectionSecurity) {
            if (indexPath.row == 2) {
                // touch id
                if (!self.touchIDSwitch) {
                    UISwitch *aSwitch = [[UISwitch alloc] init];
                    [aSwitch addTarget:self action:@selector(p_handleToggleTouchIdEnabled:) forControlEvents:UIControlEventValueChanged];
                    self.touchIDSwitch = aSwitch;
                }
                cell.accessoryView = self.touchIDSwitch;
                self.touchIDSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:CBWUserDefaultsTouchIdEnabledKey];
            }
        }
        
        // set icloud cell stuff
        if (indexPath.section == kProfileSectionBackup) {
            if (indexPath.row == 1) {
                // iCloud
                cell.detailTextLabel.text = [[[NSUserDefaults standardUserDefaults] objectForKey:CBWUserDefaultsiCloudSyncDateKey] stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
                if (!self.iCloudSwitch) {
                    UISwitch *aSwitch = [[UISwitch alloc] init];
                    [aSwitch addTarget:self action:@selector(p_handleToggleiCloudEnabled:) forControlEvents:UIControlEventValueChanged];
                    self.iCloudSwitch = aSwitch;
                }
                cell.accessoryView = self.iCloudSwitch;
                self.iCloudSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:CBWUserDefaultsiCloudEnabledKey];
            }
        }
        // set sign out with danger color
        if (indexPath.section == kProfileSectionSignOut) {
            cell.textLabel.textColor = [UIColor CBWDangerColor];
        }
    }
    
    return cell;
}
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self reportActivity:@"selectCell"];
    
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
        case kProfileSectionSecurity: {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            switch (indexPath.row) {
                case 0: {
                    PasswordViewController *settingsViewController = [[PasswordViewController alloc] init];
                    [self.navigationController pushViewController:settingsViewController animated:YES];
                    break;
                }
                    
                case 1: {
                    UIAlertController *hintController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Profile Cell change_hint", @"CBW", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
                    [hintController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                        textField.placeholder = NSLocalizedStringFromTable(@"Placeholder enter_new_hint", @"CBW", nil);
                        textField.text = [SSKeychain passwordForService:CBWKeychainHintService account:CBWKeychainAccountDefault];
                    }];
                    
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"CBW", nil) style:UIAlertActionStyleCancel handler:nil];
                    [hintController addAction:cancel];
                    
                    UIAlertAction *save = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Save", @"CBW", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        UITextField *hintField = [[hintController textFields] firstObject];
                        NSString *hint = hintField.text;
                        if (hint.length > 0) {
                            if ([SSKeychain setPassword:hint forService:CBWKeychainHintService account:CBWKeychainAccountDefault]) {
                                [self alertMessage:NSLocalizedStringFromTable(@"Success", @"CBW", nil) withTitle:@""];
                                // 重新备份到 iCloud
                                [CBWBackup saveToCloudKitWithCompletion:^(NSError *error) {
                                    // TODO: handle error
                                    if (error) {
                                        DLog(@"changed hint, update iCloud backup failed. \n%@", error);
                                    }
                                }];
                            } else {
                                [self alertMessage:NSLocalizedStringFromTable(@"Alert Message update_hint_error", @"CBW", nil) withTitle:@""];
                            }
                        } else {
                            [self alertErrorMessage:NSLocalizedStringFromTable(@"Alert Message empty_hint", @"CBW", nil)];
                        }
                    }];
                    [hintController addAction:save];
                    
                    [self presentViewController:hintController animated:YES completion:nil];
                    
                    break;
                }
                    
                case 2: {
                    [self p_handleToggleTouchIdEnabled:nil];
                    break;
                }
            }
            break;
        }
            
        case kProfileSectionBackup: {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            if (indexPath.row == 0) {
                // export
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                cell.accessoryView = indicator;
                [indicator startAnimating];
                [self p_exportBackupImageToPhotoLibraryWithCell:cell];
            } else if (indexPath.row == 1) {
                // icloud
                [self p_handleToggleiCloudEnabled:nil];
            }
            break;
        }
        case kProfileSectionSignOut: {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Alert Title sign_out", @"CBW", nil) message:NSLocalizedStringFromTable(@"Alert Message sign_out", @"CBW", nil) preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.secureTextEntry = YES;
                textField.placeholder = NSLocalizedStringFromTable(@"Placeholder master_password", @"CBW", nil);
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"CBW", nil) style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancel];
            
            UIAlertAction *backupAndDelete = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Alert Action backup_delete", @"CBW", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSString *code = [alert.textFields firstObject].text;
                if (code.length == 0) {
                    [self alertErrorMessage:NSLocalizedStringFromTable(@"Alert Message need_current_password", @"CBW", nil)];
                } else {
                    if (![[Guard globalGuard] checkInWithCode:code]) {
                        [self alertErrorMessage:NSLocalizedStringFromTable(@"Alert Message invalid_master_password", @"CBW", nil)];
                    } else {
                        [CBWBackup saveToLocalPhotoLibraryWithCompleiton:^(NSURL *assetURL, NSError *error) {
                            if (error) {
                                NSLog(@"export to photo library error: \n%@", error);
                                [self alertMessage:error.localizedDescription withTitle:NSLocalizedStringFromTable(@"Error", @"CBW", nil)];
                            } else {
                                [[Guard globalGuard] signOut];
                            }
                        }];
                    }
                    
                }
            }];
            [alert addAction:backupAndDelete];
            
            UIAlertAction *delete = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Delete", @"CBW", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSString *code = [alert.textFields firstObject].text;
                if (code.length == 0) {
                    [self alertErrorMessage:NSLocalizedStringFromTable(@"Alert Message need_current_password", @"CBW", nil)];
                } else {
                    if (![[Guard globalGuard] checkInWithCode:code]) {
                        [self alertErrorMessage:NSLocalizedStringFromTable(@"Alert Message invalid_master_password", @"CBW", nil)];
                    } else {
                        [[Guard globalGuard] signOut];
                    }
                }
            }];
            [alert addAction:delete];
            [self presentViewController:alert animated:YES completion:^{
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            }];
            break;
        }
    }
}

@end
