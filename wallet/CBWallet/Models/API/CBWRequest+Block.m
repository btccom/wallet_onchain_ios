//
//  CBWRequest+Block.m
//  CBWallet
//
//  Created by Zin on 16/3/30.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRequest+Block.h"

NSString *const BlockHeightKey = @"height";

@implementation CBWRequest (Block)

- (void)blockLatestWithCompletion:(CBWRequestCompletion)completion {
    NSString *path = @"block/latest";
    [self requestWithPath:path parameters:nil completion:completion];
}

@end
