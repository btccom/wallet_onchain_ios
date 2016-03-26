//
//  RecordObject.h
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseManager.h"

@class RecordObjectStore;

@interface RecordObject : NSObject

/// 新记录 rid = -1，保存后会被更新
@property (nonatomic, assign) NSInteger rid;
@property (nonatomic, strong, nonnull) NSDate *creationDate;
@property (nonatomic, strong, nonnull) NSDate *modificationDate;
@property (nonatomic, weak, nullable) RecordObjectStore *store;

/// 新建记录在内存中，需要调用 saveWithError: 写入数据库
+ (nonnull instancetype)newRecordInStore:(nonnull RecordObjectStore *)store;

/// 从内存中删除记录，并删除数据库记录
//- (void)deleteFromStore:(nonnull RecordObjectStore *)store;

- (void)saveWithError:(NSError * _Nullable * _Nullable)error;
@end
