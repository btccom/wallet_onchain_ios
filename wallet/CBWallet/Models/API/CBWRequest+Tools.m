//
//  CBWRequest+Tools.m
//  CBWallet
//
//  Created by Zin on 16/3/31.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRequest+Tools.h"

@implementation CBWRequest (Tools)

- (void)toolsPublishTxHex:(NSString *)hex withCompletion:(CBWRequestCompletion)completion {
    NSString *path = @"tools/tx-publish";
    NSString *method = @"POST";
    NSDictionary *parameters = @{@"rawhex": hex};
    [self requestWithPath:path method:method parameters:parameters completion:completion];
}

@end
