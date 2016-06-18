//
//  DatabaseManager.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/21.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

typedef NS_ENUM(NSInteger, CBWDatabaseChangeType) {
    /// failed
    CBWDatabaseChangeTypeFail = -1,
    /// exist, and no need to be updated
    CBWDatabaseChangeTypeNone,
    /// insert
    CBWDatabaseChangeTypeInsert,
    /// exist, update
    CBWDatabaseChangeTypeUpdate
};

extern NSString *const DatabaseManagerDBPath;

// tables
extern NSString *const DatabaseManagerTableAccount;
extern NSString *const DatabaseManagerTableAddress;
extern NSString *const DatabaseManagerTableTX;
extern NSString *const DatabaseManagerTableRecipient;

// columns
// common
/// integer
extern NSString *const DatabaseManagerColRid;
/// date
extern NSString *const DatabaseManagerColCreationDate;
/// date
extern NSString *const DatabaseManagerColModificationDate;
/// integer
extern NSString *const DatabaseManagerColIdx;
/// text / string
extern NSString *const DatabaseManagerColAddress;
/// text / string
extern NSString *const DatabaseManagerColLabel;

// in account
/// integer / bool
extern NSString *const DatabaseManagerColCustomDefaultEnabled;

// in address
/// integer / bool
extern NSString *const DatabaseManagerColArchived;
/// integer / bool
extern NSString *const DatabaseManagerColDirty;
/// integer / bool
extern NSString *const DatabaseManagerColInternal;
/// integer / long long in satoshi
extern NSString *const DatabaseManagerColBalance;
/// integer / long long in satoshi
extern NSString *const DatabaseManagerColReceived;
/// integer / long long in satoshi
extern NSString *const DatabaseManagerColSent;
/// integer
extern NSString *const DatabaseManagerColTxCount;
/// integer
extern NSString *const DatabaseManagerColAccountRid;
/// integer
extern NSString *const DatabaseManagerColAccountIdx;

@interface CBWDatabaseManager : NSObject

+ (instancetype)defaultManager;
+ (FMDatabase *)installDb;
+ (BOOL)deleteAllDatas;

+ (NSString *)dbPath;

- (FMDatabase *)db;

@end

#import "CBWDatabaseManager+Account.h"
#import "CBWDatabaseManager+Address.h"
#import "CBWDatabaseManager+TX.h"
