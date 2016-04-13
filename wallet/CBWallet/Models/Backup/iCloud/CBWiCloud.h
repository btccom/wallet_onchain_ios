//
//  CBWiCloud.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/10.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CBWiCloudFetchCompletion) (NSError *error, id data);

@interface CBWiCloud : NSObject

+ (void)toggleiCloudBySwith:(UISwitch *)aSwitch inViewController:(UIViewController *)viewController;
+ (BOOL)isiCloudAccountSignedIn;

/// 直接存储备份数据
+ (void)saveBackupData;
/// 存储数据到 container
+ (void)saveData:(id)data withFileName:(NSString *)fileName completion:(void(^)(BOOL success))completion;
/// 获取备份数据
- (void)fetchBackupDataWithCompletion:(CBWiCloudFetchCompletion)completion;
/// 从 iCloud 获取数据
- (void)fetchWithFileName:(NSString *)fileName withCompletion:(CBWiCloudFetchCompletion)completion;

@end
