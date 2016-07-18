//
//  AccountsManagerViewController.m
//  CBWallet
//
//  Created by Zin on 16/4/18.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AccountsManagerViewController.h"
#import "Database.h"

typedef NS_ENUM(NSUInteger, kAccountsManagerSection) {
    kAccountsManagerSectionAccounts,
    kAccountsManagerSectionAnalytics
};

@interface AccountsManagerViewController ()

@property (nonatomic, strong) NSDictionary *accountAnalytics;
@property (nonatomic, weak) UIView *accountsBackgroundView;

@end

@implementation AccountsManagerViewController

- (NSDictionary *)accountAnalytics {
    if (!_accountAnalytics) {
        _accountAnalytics = [CBWAccountStore analyzeAllAccountAddresses];
    }
    return _accountAnalytics;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedStringFromTable(@"Navigation manage_accounts", @"CBW", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_create"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleCreateAccount:)];
    
    self.tableView.backgroundColor = [UIColor CBWSeparatorColor];
    
    [self enableRevealInteraction];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.accountsBackgroundView) {
        UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
        CGRect whiteViewFrame = [self.tableView rectForSection:kAccountsManagerSectionAccounts];
        whiteViewFrame.size.height += whiteViewFrame.origin.y + CGRectGetHeight(view.frame);
        whiteViewFrame.origin.y = -CGRectGetHeight(view.frame);
        UIView *whiteView = [[UIView alloc] initWithFrame:whiteViewFrame];
        whiteView.backgroundColor = [UIColor CBWBackgroundColor];
        [view addSubview:whiteView];
        [self.tableView insertSubview:view atIndex:0];
        self.accountsBackgroundView = view;
    }
}

#pragma mark - Private Method

- (void)p_handleCreateAccount:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Alert Title new_account", @"CBW", nil) message:NSLocalizedStringFromTable(@"Alert Message new_account", @"CBW", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedStringFromTable(@"Placeholder account_label", @"CBW", nil);
        textField.returnKeyType = UIReturnKeyDone;
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"CBW", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    
    __weak typeof(alert) weakAlert = alert;
    UIAlertAction *save = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Save", @"CBW", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = [weakAlert.textFields firstObject];
        NSString *label = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (label.length > 0) {
            [self p_createAccountWithLabel:label];
        } else {
            [self alertErrorMessage:NSLocalizedStringFromTable(@"Alert Message need_account_label", @"CBW", nil)];
        }
    }];
    [alert addAction:save];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)p_createAccountWithLabel:(NSString *)label {
    if ([CBWAccount checkLabel:label]) {
        [self alertErrorMessage:[NSString stringWithFormat:NSLocalizedStringFromTable(@"Alert Message duplicated_account_label", @"CBW", nil), label]];
        return;
    }
    NSUInteger idx = self.accountStore.count - 1;// remove watched account
    CBWAccount *account = [CBWAccount newAccountWithIdx:idx label:label inStore:self.accountStore];
    DLog(@"create account: %@ at %ld", account.label, (long)idx);
    NSError *error = nil;
    [account saveWithError:&error];
    if (error) {
        NSLog(@"create account error: %@", error);
        return;
    }
    [self.accountStore fetch];
    DLog(@"new account count: %ld", (long)(self.accountStore.count - 1));
    // created
    [[NSNotificationCenter defaultCenter] postNotificationName:CBWNotificationAccountCreated object:nil userInfo:nil];
    // reload
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;// accounts, analytics
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (kAccountsManagerSectionAnalytics == section) {
        return self.accountAnalytics.count;
    }
    return self.accountStore.count - 1;// remove watched account
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellDefaultIdentifier forIndexPath:indexPath];
    
    if (kAccountsManagerSectionAnalytics == indexPath.section) {
        NSString *key = [[[self.accountAnalytics allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row];
        NSString *keyText = [NSString stringWithFormat:@"AMA Cell %@", key];
        cell.textLabel.text = NSLocalizedStringFromTable(keyText, @"CBW", nil);
        if ([key isEqualToString:CBWAccountTotalTXCountKey]) {
            cell.detailTextLabel.text = [[self.accountAnalytics objectForKey:key] groupingString];
        } else {
            cell.detailTextLabel.text = [[self.accountAnalytics objectForKey:key] satoshiBTCString];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor CBWSeparatorColor];
        return cell;
    }
    
    CBWAccount *account = [self.accountStore recordAtIndex:indexPath.row];
    cell.textLabel.text = account.label;
    cell.detailTextLabel.text = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.backgroundColor = [UIColor CBWBackgroundColor];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (kAccountsManagerSectionAnalytics == section) {
        return NSLocalizedStringFromTable(@"Accounts Manager Section analytics", @"CBW", nil);
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (kAccountsManagerSectionAnalytics == indexPath.section) {
        return CBWCellHeightMin;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (kAccountsManagerSectionAnalytics == section) {
        return CBWCellHeightDefault;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DefaultSectionHeaderView *view = (DefaultSectionHeaderView *)[super tableView:tableView viewForHeaderInSection:section];
    view.contentView.backgroundColor = [UIColor CBWSeparatorColor];
    return view;
}

#pragma mark <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (kAccountsManagerSectionAnalytics == indexPath.section) {
        return;
    }
    
    CBWAccount *account = [self.accountStore recordAtIndex:indexPath.row];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Alert Title change_account_label", @"CBW", nil) message:NSLocalizedStringFromTable(@"Alert Message change_account_label", @"CBW", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedStringFromTable(@"Placeholder account_label", @"CBW", nil);
        textField.text = account.label;
        textField.returnKeyType = UIReturnKeyDone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"CBW", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    
    __weak typeof(alert) weakAlert = alert;
    UIAlertAction *save = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Save", @"CBW", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = [weakAlert.textFields firstObject];
        NSString *label = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (label.length > 0) {
            
            if ([account.label isEqualToString:label]) {
                return;
            } else {
                if ([CBWAccount checkLabel:label]) {
                    [self alertErrorMessage:[NSString stringWithFormat:NSLocalizedStringFromTable(@"Alert Message duplicated_account_label", @"CBW", nil), label]];
                    return;
                }
            }
            
            account.label = label;
            NSError *error = nil;
            [account saveWithError:&error];
            if (!error) {
                // updated
                [[NSNotificationCenter defaultCenter] postNotificationName:CBWNotificationAccountUpdated object:nil userInfo:nil];
                // reload
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            
        } else {
            [self alertErrorMessage:NSLocalizedStringFromTable(@"Alert Message need_account_label", @"CBW", nil)];
        }
    }];
    [alert addAction:save];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
