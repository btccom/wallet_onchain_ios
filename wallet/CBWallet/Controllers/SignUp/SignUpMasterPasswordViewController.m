//
//  SignUpMasterPasswordViewController.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/5/31.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "SignUpMasterPasswordViewController.h"

#import "PrimarySolidButton.h"

#import "UIViewController+Appearance.h"
#import "UIViewController+AlertMessage.h"
#import "NSString+Password.h"

@interface SignUpMasterPasswordViewController ()<UITextFieldDelegate>

@property (nonatomic, weak) UITextField *passwordField;
@property (nonatomic, weak) UITextField *confirmPasswordField;
@property (nonatomic, weak) UITextField *hintField;
@property (nonatomic, weak) UIButton *nextButton;

@property (nonatomic, weak) UIScrollView *scrollView;

@end

@implementation SignUpMasterPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat padding = CBWLayoutCommonPadding;
    CGFloat top = 64.f;
    
    // scroll view
    CGRect scrollFrame = self.view.bounds;
    scrollFrame.origin.y = top;
    scrollFrame.size.height -= top;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:scrollView];
    _scrollView = scrollView;
    
    // password
    UITextField *passwordField = [self p_newTextFieldAtY: HD_IMAGE_PORTRAIT_HEIGHT + padding - top placeholder:NSLocalizedStringFromTable(@"Placeholder master_password", @"CBW", nil)];
    passwordField.secureTextEntry = YES;
    passwordField.returnKeyType = UIReturnKeyNext;
    passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [scrollView addSubview:passwordField];
    _passwordField = passwordField;
    [scrollView addSubview:[self generateSeparatorWithFrame:CGRectOffset(passwordField.frame, 0, CBWCellHeightDefault)]];
    
    if (self.recoverEnabled) {
        
        // hint label
        UIFont *tipFont = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        CGFloat tipWidth = CGRectGetWidth(passwordField.frame);
        CGFloat tipHeight = CGRectGetHeight(self.view.frame);
        NSString *tip = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Tip hint_%@", @"CBW", nil), self.hint];
        tipHeight = [tip sizeWithFont:tipFont maxSize:CGSizeMake(tipWidth, tipHeight)].height;
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, CGRectGetMaxY(passwordField.frame) + CBWLayoutInnerSpace, tipWidth, tipHeight)];
        tipLabel.font = tipFont;
        tipLabel.textColor = [UIColor CBWSubTextColor];
        tipLabel.text = tip;
        [scrollView addSubview:tipLabel];
        
        // next button
        CGRect nextButtonFrame = passwordField.frame;
        nextButtonFrame.origin.y = CGRectGetMaxY(tipLabel.frame) + padding;
        PrimarySolidButton *nextButton = [[PrimarySolidButton alloc] initWithFrame:nextButtonFrame];
        nextButton.enabled = NO;
        [nextButton setTitle:NSLocalizedStringFromTable(@"Button recover", @"CBW", nil) forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(p_handleNext) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:nextButton];
        _nextButton = nextButton;
        
    } else {
        // confirm password
        UITextField *confirmPasswordField = [self p_newTextFieldAtY:CGRectGetMaxY(passwordField.frame) placeholder:NSLocalizedStringFromTable(@"Placeholder confirm_master_password", @"CBW", nil)];
        confirmPasswordField.secureTextEntry = YES;
        confirmPasswordField.returnKeyType = UIReturnKeyNext;
        confirmPasswordField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [scrollView addSubview:confirmPasswordField];
        _confirmPasswordField = confirmPasswordField;
        [scrollView addSubview:[self generateSeparatorWithFrame:CGRectOffset(confirmPasswordField.frame, 0, CBWCellHeightDefault)]];
        
        // password tip label
        UIFont *tipFont = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        CGFloat tipWidth = CGRectGetWidth(confirmPasswordField.frame);
        CGFloat tipHeight = CGRectGetHeight(self.view.frame);
        NSString *tip = NSLocalizedStringFromTable(@"Tip about_master_password", @"CBW", nil);
        tipHeight = [tip sizeWithFont:tipFont maxSize:CGSizeMake(tipWidth, tipHeight)].height;
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, CGRectGetMaxY(confirmPasswordField.frame) + CBWLayoutInnerSpace, tipWidth, tipHeight)];
        tipLabel.numberOfLines = 0;
        tipLabel.font = tipFont;
        tipLabel.textColor = [UIColor CBWSubTextColor];
        tipLabel.text = tip;
        [scrollView addSubview:tipLabel];
        
        // hint
        UITextField *hintField = [self p_newTextFieldAtY:CGRectGetMaxY(tipLabel.frame) + padding placeholder:NSLocalizedStringFromTable(@"Placeholder hint", @"CBW", nil)];
        hintField.returnKeyType = UIReturnKeyDone;
        hintField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [scrollView addSubview:hintField];
        _hintField = hintField;
        [scrollView addSubview:[self generateSeparatorWithFrame:CGRectOffset(hintField.frame, 0, CBWCellHeightDefault)]];
        
        // next button
        PrimarySolidButton *nextButton = [[PrimarySolidButton alloc] initWithFrame:CGRectOffset(hintField.frame, 0, CBWCellHeightDefault + CBWLayoutCommonPadding)];
        nextButton.enabled = NO;
        [nextButton setTitle:NSLocalizedStringFromTable(@"Button next", @"CBW", nil) forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(p_handleNext) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:nextButton];
        _nextButton = nextButton;
    }
    
    // background
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, HD_IMAGE_PORTRAIT_HEIGHT - top, CGRectGetWidth(scrollFrame), SCREEN_HEIGHT - HD_IMAGE_PORTRAIT_HEIGHT)];
    background.backgroundColor = [UIColor CBWWhiteColor];
    [scrollView insertSubview:background atIndex:0];
    
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(scrollFrame), CGRectGetMaxY(self.nextButton.frame) + CBWLayoutCommonPadding);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(p_toggleKeyboard:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(p_toggleKeyboard:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DLog(@"sign up master password dealloc!");
}

- (void)becomeFirstResponder {
    if (self.passwordField.text.length == 0) {
        [self.passwordField becomeFirstResponder];
    }
}

#pragma mark - Private Method

- (UITextField *)p_newTextFieldAtY:(CGFloat)y placeholder:(NSString *)placeholder {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(CBWLayoutCommonPadding, y, SCREEN_WIDTH - 2 * CBWLayoutCommonPadding, CBWCellHeightDefault)];
    textField.placeholder = placeholder;
    textField.delegate = self;
    [textField addTarget:self action:@selector(p_handleEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    return textField;
}

- (void)p_toggleKeyboard:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    
    CGFloat kbTop = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    CGRect finalFrame = self.scrollView.frame;
    finalFrame.size.height = kbTop - 64.f;
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    UIViewAnimationOptions options = animationCurve << 16;
    [UIView animateWithDuration:animationDuration delay:0.0f options:options animations:^{
        self.scrollView.frame = finalFrame;
     } completion:nil];
}

- (void)p_handleEditingChanged:(UITextField *)textField {
    BOOL valid = YES;
    
    valid = valid && self.passwordField.text.length > 0;
    if (self.confirmPasswordField) {
        valid = valid && self.confirmPasswordField.text.length > 0;
    }
    if (self.hintField) {
        valid = valid && self.hintField.text.length > 0;
    }
    
    self.nextButton.enabled = valid;
}

- (void)p_handleNext {
    [self.view endEditing:YES];
    
    NSString *password = self.passwordField.text;
    
    NSMutableArray *messages = [NSMutableArray array];
    
    // valid password for create
    if (self.recoverEnabled) {
        if (password.length == 0) {
            [messages addObject:NSLocalizedStringFromTable(@"Alert Message need_master_password", @"CBW", nil)];
        }
    } else {
        double score = [password passwordStrength];
        DLog(@"score: %f", score);
        if (score < 60) {
            [messages addObject:NSLocalizedStringFromTable(@"Alert Message need_strong_password", @"CBW", @"Please input a strong password.")];
        }
    }
    
    // confirm
    if (self.confirmPasswordField) {
        NSString *confirmPassword = self.confirmPasswordField.text;
        if (![password isEqualToString:confirmPassword]) {
            [messages addObject:NSLocalizedStringFromTable(@"Alert Message confirm_password", @"CBW", @"Please confirm password.")];
        }
    }
    
    // hint
    NSString *hint = self.hint;
    if (self.hintField) {
        hint = self.hintField.text;// allow white space
        if (hint.length == 0) {
            [messages addObject:NSLocalizedStringFromTable(@"Alert Message need_hint", @"CBW", nil)];
        }
    }
    
    if (messages.count > 0) {
        // alert message
        [self alertErrorMessage:[messages componentsJoinedByString:@"\n"]];
        return;
    }
    
    DLog(@"next");
    [self.delegate signUpMasterPasswordViewController:self didInputPassword:password andHint:hint];
}

#pragma mark - <UITextFieldDelegate>
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.passwordField]) {
        [self.confirmPasswordField becomeFirstResponder];
    } else if ([textField isEqual:self.confirmPasswordField]) {
        [self.hintField becomeFirstResponder];
    } else if ([textField isEqual:self.hintField]) {
        [self p_handleNext];
    }
    return YES;
}

@end
