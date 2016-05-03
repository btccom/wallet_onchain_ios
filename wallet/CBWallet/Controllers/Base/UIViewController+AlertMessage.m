//
//  UIViewController+AlertMessage.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/20.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "UIViewController+AlertMessage.h"

@implementation UIViewController (AlertMessage)

- (void)alertMessageWithInvalidAddress:(NSString *)addressString {
    NSString *message = NSLocalizedStringFromTable(@"Alert Message invalid_address", @"CBW", nil);
    if (addressString.length > 0) {
        message = [message stringByAppendingFormat:@"\n%@", addressString];
    }
    [self alertErrorMessage:message];
}

- (void)alertMessage:(NSString *)message withTitle:(NSString *)title {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okay = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Okay", @"CBW", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okay];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertErrorMessage:(NSString *)message {
    [self alertMessage:message withTitle:NSLocalizedStringFromTable(@"Error", @"CBW", nil)];
}

@end
