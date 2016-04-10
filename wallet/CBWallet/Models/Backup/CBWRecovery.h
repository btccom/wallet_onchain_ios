//
//  CBWRecovery.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/10.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBWRecovery : NSObject

/// 尝试从 iCloud 恢复数据，数据会在 block 中返回
- (void)prepareForiCloudWithCompletion:(void(^)(NSError *error, NSDictionary *data))completion;

/// 验证数据，从相册中恢复时，需要校验数据完整性
- (BOOL)validateData:(NSDictionary *)data;

/// 使用密码进行恢复，解密成功，将加密数据保存在 keychain，使用数据保存在数据库
- (void)recoverWithCode:(NSString *)code;

@end
