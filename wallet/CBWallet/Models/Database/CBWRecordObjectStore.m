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
    DLog(@"%p remove all records", self);
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

- (BOOL)addRecord:(__kindof CBWRecordObject *)record {
    return [self addRecord:record ASC:NO];
}

- (BOOL)addRecord:(__kindof CBWRecordObject *)record ASC:(BOOL)ASC {
    if (!record) {
        return NO;
    }
    if ([records containsObject:record]) {
        return NO;
    }
    record.store = self;
//    DLog(@"store add record: %@", record);
    if (ASC) {
        [records addObject:record];
    } else {
        [records insertObject:record atIndex:0]; /// DESC
    }
    return YES;
}

- (void)deleteRecord:(CBWRecordObject *)record {
    if ([records containsObject:record]) {
        [self willChangeValueForKey:CBWRecordObjectStoreCountKey];
        [records removeObject:record];
        [self didChangeValueForKey:CBWRecordObjectStoreCountKey];
    }
}

- (BOOL)containsRecord:(CBWRecordObject *)record {
    return [records containsObject:record];
}

@end
