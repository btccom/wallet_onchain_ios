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
//- (void)prepareForiCloudWithCompletion:(void(^)(NSError *error, id data))completion;

/// 从相册中恢复
- (instancetype)initWithAssetURL:(NSURL *)assetURL;
- (void)fetchAssetDatasWithCompletion:(void(^)(NSError *error))completion;
/// 传入数据，例如从 iCloud 中恢复
- (instancetype)initWithDatas:(NSArray *)datas;

- (void)fetchCloudKitDataWithCompletion:(void(^)(NSError *error))completion;

/// 使用密码进行恢复，解密成功，将加密数据保存在 keychain，使用数据保存在数据库
- (BOOL)recoverWithCode:(NSString *)code;

- (NSString *)hint;

@end
