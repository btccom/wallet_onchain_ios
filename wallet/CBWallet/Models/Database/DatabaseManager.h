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

@interface DatabaseManager : NSObject

+ (instancetype)defaultManager;

- (FMDatabase *)db;

@end

#import "DatabaseManager+Account.h"
