//
//  RecordObjectStore.h
//  CBWallet
//
//  Created by Zin on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecordObject.h"

@interface RecordObjectStore : NSObject {
    NSMutableArray<RecordObject *> *records;
}

/// 获取数据库中全部记录
- (void)fetch;

- (nullable id)recordAtIndex:(NSUInteger)idx;
/// 加入内存
- (void)addRecord:(nullable RecordObject *)record;
/// 移出内存
- (void)deleteRecord:(nullable RecordObject *)record;

@end
