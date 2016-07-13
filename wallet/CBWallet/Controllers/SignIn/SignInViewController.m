//
//  SignInViewController.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/5/31.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "SignInViewController.h"

#import "UIViewController+AlertMessage.h"
#import "UIView+Yoyo.h"

#import "Guard.h"

#import "SSKeychain.h"

@import LocalAuthentication;

@interface SignInViewController ()<UITextFieldDelegate>

@property (nonatomic, weak) UIView *inputView;
@property (nonatomic, weak) UITextField *masterPasswordField;
@property (nonatomic, weak) UIButton *unlockButton;

@property (nonatomic, assign) BOOL displayingHint;
@property (nonatomic, assign, getter=isKeyboardShown) BOOL keyboardShown;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // background
    UIControl *background = [[UIControl alloc] initWithFrame:self.view.bounds];
    [background addTarget:self action:@selector(p_handleEndEditing) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:background];
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundImage.image = [UIImage imageNamed:@"background"];
    [background addSubview:backgroundImage];
    
    // logo
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LaunchLogo"]];
    logoView.frame = CGRectOffset(logoView.bounds, (SCREEN_WIDTH - CGRectGetWidth(logoView.bounds)) / 2, 64);
    [self.view addSubview:logoView];
    
    CGFloat padding = CBWLayoutCommonPadding;
    
    // input view
    UIView *inputView = [[UIView alloc ] initWithFrame:CGRectMake(padding, SCREEN_HEIGHT_GOLDEN_SMALL, SCREEN_WIDTH - padding * 2, CBWCellHeightDefault)];
    inputView.backgroundColor = [UIColor CBWWhiteColor];
    inputView.layer.cornerRadius = CBWCornerRadiusMini;
    inputView.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.2f].CGColor;
    inputView.layer.shadowOffset = CGSizeMake(0, 2.f);
    inputView.layer.shadowRadius = 4.f;
    inputView.layer.shadowOpacity = 0.7f;
    [self.view addSubview:inputView];
    _inputView = inputView;
    
    // master password textfield
    UITextField *masterPasswordTextField = [[UITextField alloc] initWithFrame:CGRectOffset(CGRectInset(inputView.bounds, CBWCellHeightDefault / 2.f, 0), - CBWCellHeightDefault / 2.f, 0)];
    masterPasswordTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CBWLayoutInnerSpace, CBWCellHeightDefault)];
    masterPasswordTextField.leftViewMode = UITextFieldViewModeAlways;
    masterPasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    masterPasswordTextField.placeholder = NSLocalizedStringFromTable(@"Placeholder master_password", @"CBW", nil);
    masterPasswordTextField.secureTextEntry = YES;
    masterPasswordTextField.returnKeyType = UIReturnKeyGo;
    [masterPasswordTextField addTarget:self action:@selector(p_handleEditingDidBegin) forControlEvents:UIControlEventEditingDidBegin];
    [masterPasswordTextField addTarget:self action:@selector(p_handleEditingChanged) forControlEvents:UIControlEventEditingChanged];
    [masterPasswordTextField addTarget:self action:@selector(p_handleEditingDidEnd) forControlEvents:UIControlEventEditingDidEnd];
    masterPasswordTextField.delegate = self;
    [inputView addSubview:masterPasswordTextField];
    _masterPasswordField = masterPasswordTextField;
    
    // unlock button
    UIButton *unlockButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(inputView.frame) - CBWCellHeightDefault, 0, CBWCellHeightDefault, CBWCellHeightDefault)];
    unlockButton.enabled = NO;
    [unlockButton setImage:[UIImage imageNamed:@"navigation_next"] forState:UIControlStateNormal];
    [unlockButton addTarget:self action:@selector(p_handleUnlock) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:unlockButton];
    _unlockButton = unlockButton;
    
    // hint button
    UIButton *hintButton = [[UIButton alloc ] initWithFrame:CGRectOffset(inputView.frame, 0, CBWCellHeightDefault + padding)];
    [hintButton setTitle:NSLocalizedStringFromTable(@"Button hint", @"CBW", nil) forState:UIControlStateNormal];
    [hintButton addTarget:self action:@selector(p_toggleHint:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hintButton];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Method
- (void)showKeyboard {
    DLog(@"show keyboard");
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:CBWUserDefaultsTouchIdEnabledKey]) {
    if (![[SSKeychain passwordForService:CBWKeychainTouchIDService account:CBWKeychainAccountDefault] isEqualToString:CBWKeychainTouchIDON]) {
        [self.masterPasswordField becomeFirstResponder];
        return;
    }
    
    if (self.isKeyboardShown) {
        return;
    }
    
    self.keyboardShown = YES;
    LAContext *context = [LAContext new];
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"Alert Message verify_touchid", nil) reply:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    // TODO: check domain status
                    self.masterPasswordField.text = [SSKeychain passwordForService:CBWKeychainMasterPasswordService account:CBWKeychainAccountDefault];
                    if (![self p_handleUnlock]) {
                        NSLog(@"delete wrong password in keychain");
                    }
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
                            [self.masterPasswordField becomeFirstResponder];
                        }];
                        [alertController addAction:okay];
                        [self presentViewController:alertController animated:YES completion:nil];
                    } else {
                        NSLog(@"message: %@, error: %@", message, error);
                        [self.masterPasswordField becomeFirstResponder];
                    }
                }
            });
        }];
    }
}

#pragma mark - Private Method
- (void)p_handleEndEditing {
    [self.view endEditing:YES];
}
- (void)p_handleEditingDidBegin {
}
- (void)p_handleEditingChanged {
    self.unlockButton.enabled = self.masterPasswordField.text.length > 0;
}
- (void)p_handleEditingDidEnd {
}
- (BOOL)p_handleUnlock {
    DLog(@"handle unlock");
    
    NSString *password = self.masterPasswordField.text;
    
    if (password.length == 0) {
        [self.inputView yoyoWithOffset:CGSizeMake(10.f, 0) animateDuration:CBWAnimateDuration];
        return NO;
    }
    
    if ([[Guard globalGuard] checkInWithCode:password]) {
        [self p_handleEndEditing];
        [self.delegate signInViewControllerDidUnlock:self];
        return YES;
    } else {
        [self.inputView yoyoWithOffset:CGSizeMake(10.f, 0) animateDuration:CBWAnimateDuration];
    };
    return NO;
}

- (void)p_toggleHint:(UIButton *)hintButton {
    DLog(@"toggle hint");
    [UIView animateWithDuration:CBWAnimateDurationFast animations:^{
        hintButton.alpha = 0;
    } completion:^(BOOL finished) {
        if (self.displayingHint) {
            [hintButton setTitle:NSLocalizedStringFromTable(@"Button hint", @"CBW", nil) forState:UIControlStateNormal];
            self.displayingHint = NO;
        } else {
            [hintButton setTitle:[SSKeychain passwordForService:CBWKeychainHintService account:CBWKeychainAccountDefault] forState:UIControlStateNormal];
            self.displayingHint = YES;
        }
        [UIView animateWithDuration:CBWAnimateDurationFast animations:^{
            hintButton.alpha = 1;
        }];
    }];
}

#pragma mark - <UITextFieldDelegate>
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self p_handleUnlock];
    if (textField.text.length == 0) {
        return NO;
    }
    return YES;
}

@end
