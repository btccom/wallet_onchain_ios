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
/// TODO: 如果一个地址的未花费交易很多，会触发轮询
- (void)addressUnspentWithAddressString:(nonnull NSString *)addressString completion:(nullable CBWRequestCompletion)completion;

/// 分页获取未花列表
///@param unspentHolder 用于递归传递数据
///@param completion <code>response</code>: 包含未花交易字典的数组
- (void)addressUnspentWithAddressString:(nonnull NSString *)addressString unspentHolder:(nonnull NSArray *)unspentHolder page:(NSUInteger)page completion:(nullable CBWRequestCompletion)completion;

/// 根据需要的额度，从指定地址获取未花交易列表
///@param addresses <code>[addressString or {addressString: [unspent]}]</code>，string 则获取该地址未花记录
///@param completion <code>[addressString or {addressString: [unspent]}]</code>，返回赋值后的地址及记录，<code>addresses</code>
- (void)addressesUnspentForAddresses:(nonnull NSArray *)addresses withAmount:(long long)amount progress:(void (^ _Nullable)(NSString * _Nonnull message))progress completion:(void (^ _Nullable)(NSError * _Nullable error, NSArray * _Nullable newAddresses))completion;
@end
