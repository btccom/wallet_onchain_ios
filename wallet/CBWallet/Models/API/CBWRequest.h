//
//  CBWRequest.h
//  CBWallet
//
//  Created by Zin on 16/3/28.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const _Nonnull CBWRequestAPIHost;
extern NSString *const _Nonnull CBWRequestAPIPath;
extern NSString *const _Nonnull CBWRequestAPIVersion;

extern const NSUInteger CBWRequestLimitDefault;

typedef void(^CBWRequestCompletion) (NSError * _Nullable error, NSInteger statusCode, id _Nullable response);

/// based on AFNetworking 3.0
@interface CBWRequest : NSObject

+ (nonnull NSString *)baseURLString;
- (nonnull NSString *)baseURLString;

- (void)requestWithPath:(nonnull NSString *)path parameters:(nullable NSDictionary *)parameters completion:(nullable CBWRequestCompletion)completion;

@end

#import "CBWRequest+Address.h"
