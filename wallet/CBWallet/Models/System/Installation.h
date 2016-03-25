//
//  Installation.h
//  CBWallet
//
//  Created by Zin on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Installation : NSObject
+ (nonnull NSString *)shortVersion;
+ (nonnull NSString *)bundleVersion;
+ (void)launchWithCompletion:(nullable void (^)(BOOL needUpdate, BOOL success))completion;
@end
