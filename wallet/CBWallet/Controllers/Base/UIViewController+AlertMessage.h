//
//  UIViewController+AlertMessage.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/20.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (AlertMessage)

- (void)alertMessageWithInvalidAddress:(NSString *)addressString;

- (void)alertMessage:(NSString *)message withTitle:(NSString *)title;

@end
