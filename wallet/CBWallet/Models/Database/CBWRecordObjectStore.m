//
//  RecordObjectStore.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRecordObjectStore.h"

NSString *const CBWRecordObjectStoreCountKey = @"count";

@implementation CBWRecordObjectStore

- (instancetype)init {
    self = [super init];
    if (self) {
        records = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)fetch {
    [self flush];
}

- (void)flush {
    [records removeAllObjects];
}

- (NSUInteger)count {
    return records.count;
}

- (id)recordAtIndex:(NSUInteger)idx {
    if (idx < records.count) {
        return [records objectAtIndex:idx];
    }
    return nil;
}

- (void)addRecord:(CBWRecordObject *)record {
    [self addRecord:record ASC:NO];
}

- (void)addRecord:(CBWRecordObject *)record ASC:(BOOL)ASC {
    if (!record) {
        return;
    }
    if ([records containsObject:record]) {
        return;
    }
    record.store = self;
    DLog(@"store add record: %@", record);
//    [self willChangeValueForKey:CBWRecordObjectStoreCountKey];// 无效果，在 object 里实现
    if (ASC) {
        [records addObject:record];
    } else {
        [records insertObject:record atIndex:0]; /// DESC
    }
//    [self didChangeValueForKey:CBWRecordObjectStoreCountKey];
}

- (void)deleteRecord:(CBWRecordObject *)record {
    if ([records containsObject:record]) {
        [self willChangeValueForKey:CBWRecordObjectStoreCountKey];
        [records removeObject:record];
        [self didChangeValueForKey:CBWRecordObjectStoreCountKey];
    }
}

@end
