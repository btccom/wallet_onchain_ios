//
//  DatabaseManager.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/21.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWDatabaseManager.h"
#import "Guard.h"

NSString *const DatabaseManagerDBPath = @"cbwdb.ss";// sqlite storage

// tables
NSString *const DatabaseManagerTableAccount = @"account";
NSString *const DatabaseManagerTableAddress = @"address";
NSString *const DatabaseManagerTableRecipient = @"recipient";

// columns
// common
NSString *const DatabaseManagerColRid = @"rid";
NSString *const DatabaseManagerColCreationDate = @"creationDate";
NSString *const DatabaseManagerColModificationDate = @"modificationDate";
NSString *const DatabaseManagerColIdx = @"idx";
NSString *const DatabaseManagerColAddress = @"address";
NSString *const DatabaseManagerColLabel = @"label";

// in account
NSString *const DatabaseManagerColCustomDefaultEnabled = @"customDefaultEnabled";

// in address
NSString *const DatabaseManagerColArchived = @"archived";
NSString *const DatabaseManagerColDirty = @"dirty";
NSString *const DatabaseManagerColInternal = @"internal";
NSString *const DatabaseManagerColBalance = @"balance";
NSString *const DatabaseManagerColTxCount = @"txCount";
NSString *const DatabaseManagerColAccountRid = @"accountRid";
NSString *const DatabaseManagerColAccountIdx = @"accountIdx";

@implementation CBWDatabaseManager

+ (instancetype)defaultManager {
    static id staticInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        staticInstance = [[self alloc] init];
    });
    return staticInstance;
}

+ (FMDatabase *)installDb {
    return [FMDatabase databaseWithPath:[self dbPath]];
}

+ (BOOL)deleteAllDatas {
    FMDatabase *db = [self installDb];
    BOOL deleted = NO;
    if ([db open]) {
        NSString *deleteAccountSQL = [NSString stringWithFormat:@"DELETE FROM %@", DatabaseManagerTableAccount];
        deleted = [db executeUpdate:deleteAccountSQL];
        NSString *deleteAddressSQL = [NSString stringWithFormat:@"DELETE FROM %@", DatabaseManagerTableAddress];
        [db executeUpdate:deleteAddressSQL];
        [db close];
    }
    return deleted;
}

+ (NSString *)dbPath {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:DatabaseManagerDBPath];
    return dbPath;
}

- (FMDatabase *)db {
    // FIXME: 该逻辑不实用，有待改进
//    if ([Guard globalGuard].code.length == 0) {
//        NSLog(@"need check in to access database");
//        return nil;
//    }
    return [FMDatabase databaseWithPath:[CBWDatabaseManager dbPath]];
}

@end
