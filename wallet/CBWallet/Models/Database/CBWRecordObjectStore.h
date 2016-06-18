//
//  RecordObjectStore.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBWRecordObject.h"

extern NSString *const _Nonnull CBWRecordObjectStoreCountKey;

@interface CBWRecordObjectStore : NSObject {
    NSMutableArray<__kindof CBWRecordObject *> *records;
}

/// 获取数据库中全部记录，会触发 flush
- (void)fetch;
/// 清空内存数据
- (void)flush;

@property (nonatomic, assign, readonly) NSUInteger count;
- (nullable id)recordAtIndex:(NSUInteger)idx;
/// 加入内存, DESC, insert at index:0
- (BOOL)addRecord:(__kindof CBWRecordObject * _Nullable)record;
///
- (BOOL)addRecord:(__kindof CBWRecordObject * _Nullable)record ASC:(BOOL)ASC;
/// 移出内存
- (void)deleteRecord:(nullable CBWRecordObject *)record;

- (BOOL)containsRecord:(nullable CBWRecordObject *)record;

@end
