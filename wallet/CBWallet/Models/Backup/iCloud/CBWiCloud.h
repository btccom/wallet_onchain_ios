//
//  CBWiCloud.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/10.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBWiCloud : NSObject

+ (void)toggleiCloudBySwith:(UISwitch *)aSwitch inViewController:(UIViewController *)viewController;
+ (BOOL)isiCloudAccountSignedIn;

/// 直接存储备份数据
+ (void)saveBackupData;
/// 存储数据到 container
+ (void)saveWithData:(id)data;
/// 从 iCloud 获取数据
+ (void)fetchWithCompletion:(void(^)(NSError *error, id data))completion;

@end
