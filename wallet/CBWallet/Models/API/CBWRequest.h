//
//  CBWRequest.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/28.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const _Nonnull CBWRequestAPIHost;
extern NSString *const _Nonnull CBWRequestAPIPath;
extern NSString *const _Nonnull CBWRequestAPIVersion;

extern NSString *const _Nonnull CBWRequestResponseErrorNumberKey;
extern NSString *const _Nonnull CBWRequestResponseErrorMessageKey;
extern NSString *const _Nonnull CBWRequestResponseDataKey;
extern NSString *const _Nonnull CBWRequestResponseDataTotalCountKey;
extern NSString *const _Nonnull CBWRequestResponseDataPageKey;
extern NSString *const _Nonnull CBWRequestResponseDataPageSizeKey;
extern NSString *const _Nonnull CBWRequestResponseDataListKey;

typedef void(^CBWRequestCompletion) (NSError * _Nullable error, NSInteger statusCode, id _Nullable response);

typedef BOOL(^CBWRequestCheckCompletion) (NSError * _Nullable error, NSInteger statusCode, id _Nullable response);

/// based on AFNetworking 3.0
@interface CBWRequest : NSObject

+ (nonnull instancetype)request;

+ (nonnull NSString *)baseURLString;
- (nonnull NSString *)baseURLString;

- (void)requestWithPath:(nonnull NSString *)path method:(nonnull NSString *)method parameters:(nullable NSDictionary *)parameters completion:(nullable CBWRequestCompletion)completion;
- (void)requestWithPath:(nonnull NSString *)path parameters:(nullable NSDictionary *)parameters completion:(nullable CBWRequestCompletion)completion;

@end

#import "CBWRequest+Errors.h"
#import "CBWRequest+Address.h"
#import "CBWRequest+Block.h"
#import "CBWRequest+Transaction.h"
#import "CBWRequest+Tools.h"
