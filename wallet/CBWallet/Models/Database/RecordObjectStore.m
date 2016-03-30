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

- (void)addRecord:(RecordObject *)record {
    if (!record) {
        return;
    }
    if ([records containsObject:record]) {
        return;
    }
    record.store = self;
    DLog(@"store add record: %@", record);
    [records insertObject:record atIndex:0]; /// DESC
}

- (void)deleteRecord:(RecordObject *)record {
    if ([records containsObject:record]) {
        [records removeObject:record];
    }
}

@end
