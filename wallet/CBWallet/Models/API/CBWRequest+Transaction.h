//
//  CBWRequest+Transaction.h
//  CBWallet
//
//  Created by Zin on 16/3/31.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRequest.h"

@interface CBWRequest (Transaction)

/// 获取单个交易的全部信息
- (void)transactionWithHash:(nonnull NSString *)hash completion:(nullable CBWRequestCompletion)completion;
/// 获取多个交易
- (void)transactionsWithHashes:(nonnull NSArray *)hashes completion:(nullable CBWRequestCompletion)completion;

@end
