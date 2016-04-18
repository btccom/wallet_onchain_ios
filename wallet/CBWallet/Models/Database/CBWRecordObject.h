//
//  RecordObject.h
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBWDatabaseManager.h"

@class CBWRecordObjectStore;

@interface CBWRecordObject : NSObject

/// 新记录 rid = -1，保存后会被更新
@property (nonatomic, assign) long long rid;
@property (nonatomic, strong, nonnull) NSDate *creationDate;
@property (nonatomic, strong, nonnull) NSDate *modificationDate;
@property (nonatomic, weak, nullable) CBWRecordObjectStore *store;

/// 新建记录在内存中，需要调用 saveWithError: 写入数据库
+ (nonnull instancetype)newRecordInStore:(nonnull CBWRecordObjectStore *)store;

+ (nonnull instancetype)newRecord;

// 所有记录均无法删除，watched address 例外
/// 从内存中删除记录，并删除数据库记录
//- (void)deleteFromStore:(nonnull RecordObjectStore *)store;

- (void)saveWithError:(NSError * _Nullable * _Nullable)error;
@end
