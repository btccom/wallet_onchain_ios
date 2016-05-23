//
//  CBWRequest+Errors.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/1.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRequest+Errors.h"

NSString *const CBWRequestErrorDomain = @"COM.BTC.API";
NSString *const CBWRequestErrorMessageKey = @"message";

@implementation CBWRequest (Errors)

- (NSString *)errorMessageWithCode:(CBWRequestErrorCode)code {
    switch (code) {
        case CBWRequestErrorCodeNotEnoughBalance: {
            return @"Not enough balance.";
            break;
        }
            
        case CBWRequestErrorCodeUnknown: {
            return @"Unknown error.";
            break;
        }
        case CBWRequestErrorCodeNotFound: {
            return @"Not found endpoint.";
            break;
        }
        case CBWRequestErrorCodeParameterError: {
            return @"Parameter error.";
            break;
        }
    }
    return @"Undefined error.";
}

@end
