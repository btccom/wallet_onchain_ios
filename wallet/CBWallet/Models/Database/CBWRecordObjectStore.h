//
//  RecordObjectStore.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBWRecordObject.h"

@interface CBWRecordObjectStore : NSObject {
    NSMutableArray<CBWRecordObject *> *records;
}

/// 获取数据库中全部记录，会触发 flush
- (void)fetch;
/// 清空内存数据
- (void)flush;

- (NSUInteger)count;
- (nullable id)recordAtIndex:(NSUInteger)idx;
/// 加入内存, DESC, insert at index:0
- (void)addRecord:(nullable CBWRecordObject *)record;
///
- (void)addRecord:(nullable CBWRecordObject *)record ASC:(BOOL)ASC;
/// 移出内存
- (void)deleteRecord:(nullable CBWRecordObject *)record;

@end
