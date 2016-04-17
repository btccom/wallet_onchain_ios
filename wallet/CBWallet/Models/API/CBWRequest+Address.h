//
//  CBWRequest+Address.h
//  CBWallet
//
//  Created by Zin on 16/3/28.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRequest.h"

@interface CBWRequest (Address)

/// 获取地址摘要
- (void)addressSummaryWithAddressString:(nonnull NSString *)addressString completion:(nullable CBWRequestCompletion)completion;
/// 批量获取地址摘要，最多50个
- (void)addressSummariesWithAddressStrings:(nonnull NSArray *)addressStrings completion:(nullable CBWRequestCompletion)completion;
/// 获取地址交易列表
- (void)addressTransactionsWithAddressString:(nonnull NSString *)addressString page:(NSUInteger)page pagesize:(NSUInteger)pagesize completion:(nullable CBWRequestCompletion)completion;
- (void)addressTransactionsWithAddressStrings:(nonnull NSArray *)addressStrings completion:(nullable CBWRequestCompletion)completion;
/// 获取地址未花费列表
/// 如果一个地址的未花费交易很多，会触发轮询
- (void)addressUnspentWithAddressString:(nonnull NSString *)addressString completion:(nullable CBWRequestCompletion)completion;
@end
