//
//  SignInMasterPasswordViewController.m
//  wallet
//
//  Created by Zin on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "MasterPasswordViewController.h"
#import "LockScreenController.h"
#import "InitialWalletSettingViewController.h"

#import "PrimaryButton.h"
#import "InputTableViewCell.h"

@interface MasterPasswordViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) InputTableViewCell *masterPasswordCell;
@property (nonatomic, weak) InputTableViewCell *confirmMasterPasswordCell;
@property (nonatomic, weak) InputTableViewCell *hintCell;
@property (nonatomic, weak) UIButton *nextButton;

@end

@implementation MasterPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedStringFromTable(@"Navigation MasterPassword", @"CBW", @"Master Password");
    self.view.backgroundColor = [UIColor CBWWhiteColor];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor CBWWhiteColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}


#pragma mark - Private Method

- (void)p_handleCreate:(id)sender {
    [self.view endEditing:YES];
    
    InitialWalletSettingViewController *walletSettingViewController = [[InitialWalletSettingViewController alloc] init];
    walletSettingViewController.delegate = (LockScreenController *)self.navigationController;
    [self.navigationController pushViewController:walletSettingViewController animated:YES];
}

- (void)p_handleUnlock:(id)sender {
    [self.view endEditing:YES];
    
    [self.delegate masterPasswordViewController:self didInputPassword:@"master password"];
}

- (BOOL)p_handleEditingChanged:(UITextField *)textField {
    BOOL valid = YES;
    switch (self.actionType) {
        case LockScreenActionTypeSignIn: {
            valid = valid && self.masterPasswordCell.textField.text.length > 0;
            break;
        }
        case LockScreenActionTypeSignUp: {
            valid = valid && self.masterPasswordCell.textField.text.length > 0;
            valid = valid && self.confirmMasterPasswordCell.textField.text.length > 0;
            valid = valid && self.hintCell.textField.text.length > 0;
            break;
        }
    }
    self.nextButton.enabled = valid;
    return valid;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger number = 0;
    switch (self.actionType) {
        case LockScreenActionTypeSignIn:
            number = 1;
            break;
            
        case LockScreenActionTypeSignUp:
            number = 2;
            break;
    }
    return number;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 0;
    switch (section) {
        case 0: {
            // password
            switch (self.actionType) {
                case LockScreenActionTypeSignIn: {
                    // only master password
                    number = 1;
                    break;
                }
                case LockScreenActionTypeSignUp: {
                    // need confirm
                    number = 2;
                    break;
                }
            }
            break;
        }
        case 1: {
            // hint
            number = 1;
            break;
        }
    }
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [NSString stringWithFormat:@"cell-%lu-%lu", (unsigned long)indexPath.section, (unsigned long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        InputTableViewCell *inputCell = [[InputTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        [inputCell.textField addTarget:self action:@selector(p_handleEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        inputCell.textField.delegate = self;
        cell = inputCell;
    }
    
    switch (indexPath.section) {
        case 0: {
            // password
            switch (indexPath.row) {
                case 0: {
                    // master password
                    self.masterPasswordCell = (InputTableViewCell *)cell;
                    self.masterPasswordCell.textField.secureTextEntry = YES;
                    self.masterPasswordCell.textField.placeholder = NSLocalizedStringFromTable(@"Input Master Password", @"CBWallet", @"Master Password");
                    self.masterPasswordCell.textField.returnKeyType = (self.actionType == LockScreenActionTypeSignIn) ? UIReturnKeyDone : UIReturnKeyNext;
                    break;
                }
                case 1: {
                    // confirm password
                    self.confirmMasterPasswordCell = (InputTableViewCell *)cell;
                    self.confirmMasterPasswordCell.textField.secureTextEntry = YES;
                    self.confirmMasterPasswordCell.textField.placeholder = NSLocalizedStringFromTable(@"Input Confirm Master Password", @"CBWallet", @"Confirm Master Password");
                    self.confirmMasterPasswordCell.textField.returnKeyType = UIReturnKeyNext;
                }
            }
            break;
        }
        case 1: {
            // hint
            self.hintCell = (InputTableViewCell *)cell;
            self.hintCell.textField.placeholder = NSLocalizedStringFromTable(@"Input Hint", @"CBWallet", "Hint");
            self.hintCell.textField.returnKeyType = UIReturnKeyDone;
        }
    }
    
    return cell;
}

#pragma mark - <UITableViewDelegate>
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == tableView.numberOfSections - 1) {
        // last section
        // add next button
        CGFloat stageWidth = CGRectGetWidth(self.view.frame);
        
        UITableViewHeaderFooterView *view = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, stageWidth, CBWCellHeightDefault + CBWLayoutCommonVerticalPadding * 3.f)];
        
        PrimaryButton *button = [[PrimaryButton alloc] initWithFrame:CGRectMake(16.f, CBWLayoutCommonVerticalPadding * 2.f, stageWidth - 40.f, CBWCellHeightDefault)];
        [button setTitle:(self.actionType == LockScreenActionTypeSignIn ? NSLocalizedStringFromTable(@"Button MasterPassword", @"CBW", @"Master Password") : NSLocalizedStringFromTable(@"Button Create Wallet", @"CBW", @"Create Wallet")) forState:UIControlStateNormal];
        [button addTarget:self action:(self.actionType == LockScreenActionTypeSignIn ? @selector(p_handleUnlock:) : @selector(p_handleCreate:)) forControlEvents:UIControlEventTouchUpInside];
        button.enabled = NO;
        [view.contentView addSubview:button];
        self.nextButton = button;
        
        return view;
        
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == tableView.numberOfSections - 1) {
        return CBWCellHeightDefault + CBWLayoutCommonVerticalPadding * 3.f;
    }
    return 0;
}

#pragma mark - <UITextFieldDelegate>
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.returnKeyType == UIReturnKeyNext) {
        if ([textField isEqual:self.masterPasswordCell.textField]) {
            [self.confirmMasterPasswordCell.textField becomeFirstResponder];
        } else if ([textField isEqual:self.confirmMasterPasswordCell.textField]) {
            [self.hintCell.textField becomeFirstResponder];
        }
    } else if (textField.returnKeyType == UIReturnKeyDone) {
        [textField resignFirstResponder];
        if (![self p_handleEditingChanged:textField]) {
            return YES;
        }
        // valid, not empty
        if (self.actionType == LockScreenActionTypeSignIn) {
            [self p_handleUnlock:nil];
        } else {
            [self p_handleCreate:nil];
        }
    }
    return YES;
}

@end
