//
//  CBWRequest+Errors.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/1.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRequest+Errors.h"

NSString *const CBWRequestDomain = @"COM.BTC.API";
NSString *const CBWRequestErrorMessageKey = @"message";

@implementation CBWRequest (Errors)

- (NSString *)errorMessageWithCode:(CBWRequestErrorCode)code {
    return nil;
}

@end
