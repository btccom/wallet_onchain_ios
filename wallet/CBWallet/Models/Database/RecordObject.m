//
//  RecordObject.m
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "RecordObject.h"
#import "RecordObjectStore.h"

@implementation RecordObject

- (void)setModificationDate:(NSDate *)modificationDate {
    if (![_modificationDate isEqualToDate:modificationDate]) {
        if (!modificationDate) {
            return;
        }
        _modificationDate = modificationDate;
        if ([[modificationDate earlierDate:self.creationDate] isEqualToDate:modificationDate]) {
            _creationDate = modificationDate;
        }
    }
}

+ (instancetype)newRecordInStore:(RecordObjectStore *)store {
    RecordObject *record = [self new];
    [store addRecord:record];
    return record;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _modificationDate = _creationDate = [NSDate date];
        _rid = -1;
    }
    return self;
}

- (void)saveWithError:(NSError *__autoreleasing  _Nullable *)error {};

//- (void)deleteFromStore:(RecordObjectStore *)store {
//    [store deleteRecord:self];
//}

@end
