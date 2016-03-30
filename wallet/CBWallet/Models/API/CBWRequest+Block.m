//
//  CBWRequest+Block.m
//  CBWallet
//
//  Created by Zin on 16/3/30.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRequest+Block.h"

@implementation CBWRequest (Block)

- (void)blockLatestWithCompletion:(CBWRequestCompletion)completion {
    NSString *path = @"rawblock";
    NSDictionary *parameters = @{@"limit":@1};
    [self requestWithPath:path parameters:parameters completion:completion];
}

@end
