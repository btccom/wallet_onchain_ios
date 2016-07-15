//
//  BlockMonitor.m
//  CBWallet
//
//  Created by Zin on 16/6/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "BlockMonitor.h"

#import "CBWRequest.h"

NSString *const BlockMonitorNotificationNewBlock = @"notification.block.new";

@interface BlockMonitor ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign, getter=isFetching) BOOL fetching;

@end

@implementation BlockMonitor

+ (instancetype)defaultMonitor {
    static id staticInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        staticInstance = [[self alloc] init];
    });
    return staticInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _height = [[NSUserDefaults standardUserDefaults] integerForKey:CBWUserDefaultsBlockHeight];
    }
    return self;
}

- (void)begin {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(p_timerFired) userInfo:nil repeats:YES];
    }
    [_timer fire];
}

- (void)p_timerFired {
    if (!self.isFetching) {
        self.fetching = YES;
        CBWRequest *request = [[CBWRequest alloc] init];
        [request blockLatestWithCompletion:^(NSError * _Nullable error, NSInteger statusCode, id  _Nullable response) {
            self.fetching = NO;
            NSUInteger responsedBlockHeight = [[response objectForKey:BlockHeightKey] unsignedIntegerValue];
            if (responsedBlockHeight > self.height) {
                _height = responsedBlockHeight;
                [[NSNotificationCenter defaultCenter] postNotificationName:BlockMonitorNotificationNewBlock object:nil userInfo:@{BlockHeightKey: @(responsedBlockHeight)}];
                [[NSUserDefaults standardUserDefaults] setInteger:_height forKey:CBWUserDefaultsBlockHeight];
                [[NSUserDefaults standardUserDefaults] synchronize];
            };
        }];
    }
}

@end
