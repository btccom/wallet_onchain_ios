//
//  CBWRequest+Errors.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/1.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRequest.h"

extern NSString *const _Nonnull CBWRequestDomain;

typedef NS_ENUM(NSInteger, CBWRequestErrorCode) {
    CBWRequestErrorCodeUnknown = -1
};

@interface CBWRequest (Errors)

- (nullable NSString *)errorMessageWithCode:(CBWRequestErrorCode)code;

@end
