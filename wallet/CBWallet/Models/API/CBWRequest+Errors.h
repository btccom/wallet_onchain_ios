//
//  CBWRequest+Errors.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/1.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRequest.h"

extern NSString *const _Nonnull CBWRequestErrorDomain;

typedef NS_ENUM(NSInteger, CBWRequestErrorCode) {
    CBWRequestErrorCodeNotEnoughBalance = -1,
    CBWRequestErrorCodeUnknown = 0,
    CBWRequestErrorCodeNotFound = 1,
    CBWRequestErrorCodeParameterError = 2
};

@interface CBWRequest (Errors)

- (nullable NSString *)errorMessageWithCode:(CBWRequestErrorCode)code;

@end
