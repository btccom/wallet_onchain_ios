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

@class CBWTransactionStore;

typedef NS_ENUM(NSUInteger, CBWTransactionStoreChangeType) {
    CBWTransactionStoreChangeTypeInsert,
    CBWTransactionStoreChangeTypeUpdate
};

@protocol CBWTransactionStoreDelegate <NSObject>

@optional
- (void)transactionStoreWillUpdate:(CBWTransactionStore * _Nonnull)store;
- (void)transactionStore:(CBWTransactionStore * _Nonnull)store didUpdateRecord:(__kindof CBWRecordObject * _Nonnull)record atIndexPath:(NSIndexPath * _Nullable)indexPath forChangeType:(CBWTransactionStoreChangeType)changeType toNewIndexPath:(NSIndexPath * _Nullable)newIndexPath;
- (void)transactionStore:(CBWTransactionStore * _Nonnull)store didInsertSection:(NSString * _Nonnull)section atIndex:(NSUInteger)index;
- (void)transactionStoreDidUpdate:(CBWTransactionStore * _Nonnull)store;
@end

@class CBWAccount;
///
@interface CBWTransactionStore : CBWRecordObjectStore

@property (nullable, nonatomic, strong) CBWAccount *account;
//@property (nullable, nonatomic, copy) NSString *addressString;
/// 查询的相关地址，在 dashboard 可以用来判断交易是否为内部转移
@property (nullable, nonatomic, copy) NSArray *queryAddresses;

@property (nonatomic, assign) NSInteger blockHeight;

@property (nullable, nonatomic, weak) id<CBWTransactionStoreDelegate> delegate;

/// used for address
//- (nonnull instancetype)initWithAddressString:(nonnull NSString *)addressString;

/// insert txs to database after fetching from API
///@param collection NSArray or NSDictionary
- (NSInteger)insertTransactionsFromCollection:(nonnull id)collection;



///// 用于通过 api 获取到数据后，加入到 store 中
//- (void)addTransactionsFromJsonObject:(nonnull id)jsonObject isCacheNeeded:(BOOL)isCacheNeeded;
///// 用于通过 api 获取到数据后，加入到 store 中，指定查询地址
//- (void)addTransactionsFromJsonObject:(nonnull id)jsonObject isCacheNeeded:(BOOL)isCacheNeeded queryAddress:(nullable NSString *)queryAddress;
///// 重新排序，适用于从不同地址获取交易列表
//- (void)sort;
/// 按日排序后
- (NSUInteger)numberOfSections;
- (NSUInteger)numberOfRowsInSection:(NSUInteger)section;
- (nullable NSString *)dayInSection:(NSUInteger)section;
- (nullable CBWTransaction *)transactionAtIndexPath:(nonnull NSIndexPath *)indexPath;

//+ (void)deleteAllCaches;

@end
