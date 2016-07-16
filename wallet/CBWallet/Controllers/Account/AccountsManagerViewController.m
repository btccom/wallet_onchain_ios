//
//  AccountsManagerViewController.m
//  CBWallet
//
//  Created by Zin on 16/4/18.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AccountsManagerViewController.h"
#import "Database.h"

@interface AccountsManagerViewController ()

@end

@implementation AccountsManagerViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        NSLog(@"new accounts manager");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedStringFromTable(@"Navigation manage_accounts", @"CBW", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_create"] style:UIBarButtonItemStylePlain target:self action:@selector(p_handleCreateAccount:)];
    
    [self enableRevealInteraction];
}

- (void)dealloc {
    NSLog(@"accounts manager dealloc");
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.accountStore.count - 1;// remove watched account
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseTableViewCellDefaultIdentifier forIndexPath:indexPath];
    CBWAccount *account = [self.accountStore recordAtIndex:indexPath.row];
    cell.textLabel.text = account.label;
    return cell;
}

#pragma mark <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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