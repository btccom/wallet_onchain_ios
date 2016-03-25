//
//  RecordObjectStore.m
//  CBWallet
//
//  Created by Zin on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "RecordObjectStore.h"

@implementation RecordObjectStore

- (instancetype)init {
    self = [super init];
    if (self) {
        records = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)fetch {}

- (id)recordAtIndex:(NSUInteger)idx {
    if (idx < records.count) {
        return [records objectAtIndex:idx];
    }
    return nil;
}

- (void)addRecord:(RecordObject *)record {
    if ([records containsObject:record]) {
        return;
    }
    record.store = self;
    [records addObject:record];
}

- (void)deleteRecord:(RecordObject *)record {
    if ([records containsObject:record]) {
        [records removeObject:record];
    }
}

@end
