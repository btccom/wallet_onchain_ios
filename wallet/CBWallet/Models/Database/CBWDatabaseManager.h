//
//  DatabaseManager.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/21.
//  Copyright © 2016年 Bitmain. All rights reserved.
//
// TODO: 区分恢复备份及用户行为产生的数据改动，避免重复备份到 iCloud 操作
// TODO: 保存时需要检查变更状态，如果有变化再提交到 iCloud

#import <Foundation/Foundation.h>
#import "FMDB.h"

extern NSString *const DatabaseManagerDBPath;

// tables
extern NSString *const DatabaseManagerTableAccount;
extern NSString *const DatabaseManagerTableAddress;
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
/// integer
extern NSString *const DatabaseManagerColTxCount;
/// integer
extern NSString *const DatabaseManagerColAccountRid;
/// integer
extern NSString *const DatabaseManagerColAccountIdx;

@interface CBWDatabaseManager : NSObject

+ (instancetype)defaultManager;
+ (FMDatabase *)installDb;

+ (NSString *)dbPath;

- (FMDatabase *)db;

@end

#import "CBWDatabaseManager+Account.h"
#import "CBWDatabaseManager+Address.h"
