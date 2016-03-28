//
//  TransactionStore.h
//  CBWallet
//
//  Created by Zin on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "RecordObjectStore.h"
#import "Transaction.h"

/// 使用 plist 文件缓存，暂时不存入数据库
@interface TransactionStore : RecordObjectStore

@property (nonatomic, copy) NSString *addressString;
@property (nonatomic, assign, readonly, getter=isUpToDate) BOOL upToDate;

- (instancetype)initWithAddressString:(NSString *)addressString;
/// 从缓存获取交易记录
- (void)loadCache;
/// 用于通过 api 获取到数据后，加入到 store 中
- (void)addTransactionsFromJsonObject:(id)jsonObject;

@end
