//
//  RecordObject.m
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "RecordObject.h"

@implementation RecordObject

/// init fake data
- (instancetype)init {
    self = [super init];
    if (self) {
        _updatedDate = _createdDate = [NSDate date];
    }
    return self;
}

@end
