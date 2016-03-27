//
//  DatabaseManager.h
//  CBWallet
//
//  Created by Zin on 16/3/21.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

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

@interface DatabaseManager : NSObject

+ (instancetype)defaultManager;
+ (FMDatabase *)installDb;

- (FMDatabase *)db;

@end

#import "DatabaseManager+Account.h"
#import "DatabaseManager+Address.h"
