//
//  DatabaseManager.m
//  CBWallet
//
//  Created by Zin on 16/3/21.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "DatabaseManager.h"

NSString *const DatabaseManagerDBPath = @"cbdb.w";

@implementation DatabaseManager

+ (instancetype)defaultManager {
    static id staticInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        staticInstance = [[self alloc] init];
    });
    return staticInstance;
}

- (FMDatabase *)db {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:DatabaseManagerDBPath];
    return [FMDatabase databaseWithPath:dbPath];
}

@end
