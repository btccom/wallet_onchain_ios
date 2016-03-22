//
//  NSString+PBKDF2.h
//  CBWallet
//
//  Created by Zin on 16/3/22.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (PBKDF2)

/// generate pbkdf2 key with salt
///
///@return  Base64 string
- (NSString *)PBKDF2KeyWithSalt:(NSString *)salt;

@end
