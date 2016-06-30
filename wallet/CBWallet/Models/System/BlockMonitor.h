//
//  BlockMonitor.h
//  CBWallet
//
//  Created by Zin on 16/6/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const BlockMonitorNotificationNewBlock;

@interface BlockMonitor : NSObject

@property (nonatomic, assign, readonly) NSUInteger height;

+ (instancetype)defaultMonitor;

- (void)begin;

@end
