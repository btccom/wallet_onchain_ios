//
//  TransactionStore.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

// TODO: 格式化数据，按月分组

#import "CBWRecordObjectStore.h"
#import "CBWTransaction.h"

@class CBWAccount;
/// 使用 plist 文件缓存，暂时不存入数据库
@interface CBWTransactionStore : CBWRecordObjectStore

@property (nullable, nonatomic, strong) CBWAccount *account;
@property (nullable, nonatomic, copy) NSString *addressString;

@property (nonatomic, assign) NSInteger blockHeight;

- (nonnull instancetype)initWithAddressString:(nonnull NSString *)addressString;
/// 从缓存获取交易记录
- (void)loadCache;
/// 用于通过 api 获取到数据后，加入到 store 中
- (void)addTransactionsFromJsonObject:(nonnull id)jsonObject isCacheNeeded:(BOOL)isCacheNeeded;
/// 重新排序，适用于从不同地址获取交易列表
- (void)sort;

@end
