//
//  SignInMasterPasswordViewController.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "MasterPasswordViewController.h"
#import "LockScreenController.h"

#import "PrimaryButton.h"
#import "FormControlInputCell.h"

#import "SSKeychain.h"

#import "NSString+Password.h"

@import LocalAuthentication;

@interface MasterPasswordViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) FormControlInputCell *masterPasswordCell;
@property (nonatomic, weak) FormControlInputCell *confirmMasterPasswordCell;
@property (nonatomic, weak) FormControlInputCell *hintCell;
@property (nonatomic, weak) UIButton *nextButton;

@property (nonatomic, assign) BOOL isShown;

@end

@implementation MasterPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedStringFromTable(@"Navigation master_password", @"CBW", @"Master Password");
    self.view.backgroundColor = [UIColor CBWWhiteColor];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor CBWWhiteColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

- (void)showKeyboard {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:CBWUserDefaultsTouchIdEnabledKey]) {
        [self.masterPasswordCell.textField becomeFirstResponder];
        return;
    }
    
    if (self.isShown) {
        return;
    }
    self.isShown = YES;
    LAContext *context = [LAContext new];
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"Alert Message verify_touchid", nil) reply:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    // TODO: check domain status
                    [self.delegate masterPasswordViewController:self didInputPassword:[SSKeychain passwordForService:CBWKeychainMasterPasswordService account:CBWKeychainAccountDefault]];
                } else if (error) {
                    NSString *message = nil;
                    BOOL showAlert = NO;
                    switch (error.code) {
                        case LAErrorAuthenticationFailed: {
                            showAlert = YES;
                            message = NSLocalizedString(@"There was a problem verifying your identity.", nil);
                            break;
                        }
                            
                        case LAErrorUserCancel: {
                            message = NSLocalizedString(@"You canceled to enter password.", nil);
                            break;
                        }
                            
                        case LAErrorUserFallback: {
                            message = NSLocalizedString(@"You pressed password.", nil);
                            break;
                        }
                            
                        default:
                            message = NSLocalizedString(@"Touch ID may not be configured.", nil);
                            break;
                    }
                    if (showAlert) {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:message preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *okay = [UIAlertAction actionWithTitle:NSLocalizedString(@"Okay", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [self.masterPasswordCell.textField becomeFirstResponder];
                        }];
                        [alertController addAction:okay];
                        [self presentViewController:alertController animated:YES completion:nil];
                    } else {
                        NSLog(@"message: %@, error: %@", message, error);
                        [self.masterPasswordCell.textField becomeFirstResponder];
                    }
                }
            });
        }];
    }
}

#pragma mark - Private Method

- (void)p_handleNext:(id)sender {
    [self.view endEditing:YES];
    
    NSString *password = self.masterPasswordCell.textField.text;
    
    NSMutableArray *messages = [NSMutableArray array];
    
    // valid password
    if ([password passwordStrength] < 80) {
        [messages addObject:NSLocalizedStringFromTable(@"Alert Message need_strong_password", @"CBW", @"Please input a strong password.")];
    }
    
    // check confirm and hint
    if (self.actionType == LockScreenActionTypeSignUp) {
        // confirm
        NSString *confirmPassword = self.confirmMasterPasswordCell.textField.text;
        if (![password isEqualToString:confirmPassword]) {
            [messages addObject:NSLocalizedStringFromTable(@"Alert Message confirm_password", @"CBW", @"Please confirm password.")];
        }
        
        // hint
        // not happen to be empty
    }
    
    if (messages.count > 0) {
        // alert message
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Error", @"CBW", nil) message:[messages componentsJoinedByString:@"\n"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Okay", @"CBW", nil) style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [self.delegate masterPasswordViewController:self didInputPassword:password];
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
        FormControlInputCell *inputCell = [[FormControlInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
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
                    self.masterPasswordCell = (FormControlInputCell *)cell;
                    self.masterPasswordCell.textField.secureTextEntry = YES;
                    self.masterPasswordCell.textField.placeholder = NSLocalizedStringFromTable(@"Placeholder master_password", @"CBW", @"Master Password");
                    self.masterPasswordCell.textField.returnKeyType = (self.actionType == LockScreenActionTypeSignIn) ? UIReturnKeyDone : UIReturnKeyNext;
                    break;
                }
                case 1: {
                    // confirm password
                    self.confirmMasterPasswordCell = (FormControlInputCell *)cell;
                    self.confirmMasterPasswordCell.textField.secureTextEntry = YES;
                    self.confirmMasterPasswordCell.textField.placeholder = NSLocalizedStringFromTable(@"Placeholder confirm_master_password", @"CBW", @"Confirm Master Password");
                    self.confirmMasterPasswordCell.textField.returnKeyType = UIReturnKeyNext;
                    break;
                }
            }
            break;
        }
        case 1: {
            // hint
            self.hintCell = (FormControlInputCell *)cell;
            self.hintCell.textField.placeholder = NSLocalizedStringFromTable(@"Placeholder hint", @"CBW", "Hint");
            self.hintCell.textField.returnKeyType = UIReturnKeyDone;
            self.hintCell.textField.text = self.hint;
            break;
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
        [button setTitle:(self.actionType == LockScreenActionTypeSignIn ? NSLocalizedStringFromTable(@"Button master_password", @"CBW", @"Master Password") : NSLocalizedStringFromTable(@"Button create_wallet", @"CBW", @"Create Wallet")) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(p_handleNext:) forControlEvents:UIControlEventTouchUpInside];
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
        [self p_handleNext:nil];
    }
    return YES;
}

@end
