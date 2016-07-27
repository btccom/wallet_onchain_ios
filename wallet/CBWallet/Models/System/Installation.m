//
//  Installation.m
//  CBWallet
//
//  Created by Zin on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "Installation.h"
#import "CBWDatabaseManager.h"

@implementation Installation
+ (NSString *)shortVersion {
    return [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)bundleVersion {
    return [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
}
+ (void)launchWithCompletion:(void (^)(BOOL needUpdate, BOOL success))completion {
    NSInteger localVersion = [[NSUserDefaults standardUserDefaults] integerForKey:CBWUserDefaultsLocalVersion];
    NSInteger buildVersion = [[self bundleVersion] integerValue];
    if (buildVersion > localVersion) { // need to update
        // update
        if ([self p_updateFrom:localVersion to:buildVersion]) {
            // success
            NSLog(@"updated success");
            // update local version
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:buildVersion forKey:CBWUserDefaultsLocalVersion];
            if ([defaults synchronize]) {
                completion(YES, YES);
                return;
            }
        }
        // else fail
        completion(YES, NO);
    } else {
        // no need
        completion(NO, YES);
    }
}

#pragma mark - Private Method
+ (BOOL)p_updateFrom:(NSInteger)from to:(NSInteger)to {
    BOOL inited = YES;
    
    NSLog(@"update database");
    // 升级数据库
    FMDatabase *db = [CBWDatabaseManager installDb];
    if ([db open]) {
        // 读取sql schema目录
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *schemaFolder = [bundlePath stringByAppendingPathComponent:@"Schema/"];
        // 逐级执行
        NSFileManager *fileManager = [NSFileManager defaultManager];
        for (NSInteger i = from + 1; i < to + 1; i++) {
            NSString *schemaFilePath = [schemaFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.sql", (long)i]];
            BOOL fileExists = [fileManager fileExistsAtPath:schemaFilePath];
            NSLog(@"Read sql: %@, exists? %@", schemaFilePath, fileExists ? @"Yes" : @"NO");
            if (fileExists) {
                NSString *SQLContents = [NSString stringWithContentsOfFile:schemaFilePath
                                                                  encoding:NSUTF8StringEncoding
                                                                     error:nil];
                NSLog(@"%ld.sql: %@", (long)i, SQLContents);
                NSArray *sqlArray = [SQLContents componentsSeparatedByString:@";"];
                NSLog(@"Get sql: %ld", (long)sqlArray.count);
                if (sqlArray.count > 0) {
                    for (NSString *sql in sqlArray) {
                        if (sql.length > 0) {
                            NSLog(@"Excute sql: %@", sql);
                            BOOL success = [db executeUpdate:sql];
                            inited = inited && success;
                            NSLog(@"Done %d %d", success, inited);
                        }
                    }
                }
            }
            
            // 其他操作
            [self p_updateOperationOnVersion:i];
        }
        
        [db close];
    }
    
    return inited;
}

+ (void)p_updateOperationOnVersion:(NSInteger)version {}
@end
