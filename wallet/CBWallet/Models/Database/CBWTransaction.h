//
//  Transaction.h
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRecordObject.h"

typedef NS_ENUM(NSUInteger, TransactionType) {
    TransactionTypeSend = 0,
    TransactionTypeReceive,
    TransactionTypeInternal
};

@class InputItem, OutItem;

@interface CBWTransaction : CBWRecordObject

// 摘要 tx
/// string 交易哈希
@property (nonatomic, copy, readonly, nonnull) NSString *hashID;
/// 交易数量，正负值，单位 satoshi，基于地址的查询会得到一个 value，单独的交易不存在 value
@property (nonatomic, assign, readonly) long long value;
/// int 所在块高度
@property (nonatomic, assign, readonly) NSInteger blockHeight;
/// 所在块时间
@property (nonatomic, strong, readonly, nullable) NSDate *blockTime;
/// 查询地址，本地属性
@property (nonatomic, copy, nullable) NSString *queryAddress;
/// 相关地址，本地属性，数据库中保存为 json string，内部交易无此属性
@property (nonatomic, copy, readonly, nullable) NSArray *relatedAddresses;

// 详情 transaction
/// long long 该交易的手续费 = inputs value - outputs value
@property (nonatomic, assign) long long fee;
/// boolean 是否为 coinbase 交易
@property (nonatomic, assign, readonly) BOOL isCoinbase;
/// long long 输入金额
@property (nonatomic, assign, readonly) long long inputsValue;
/// int 输入数量，= inputs.count
@property (nonatomic, assign, readonly) NSUInteger inputsCount;
/// array of InputItem，本地数据库中会保存为文本
@property (nonatomic, strong, readonly, nullable) NSArray<InputItem *> *inputs;
/// long long 输出金额
@property (nonatomic, assign, readonly) long long outputsValue;
/// int 输出数量，= outputs.count
@property (nonatomic, assign, readonly) NSUInteger outputsCount;
/// array of OutItem，数据库中保存为 json string
@property (nonatomic, strong, readonly, nullable) NSArray<OutItem *> *outputs;
/// int 交易体积
@property (nonatomic, assign, readonly) NSUInteger size;
/// int 交易版本号
@property (nonatomic, assign, readonly) NSUInteger version;
/// 归属账户，本地属性
@property (nonatomic, assign, readonly) NSInteger accountIDX;


// calculated properties
/// 交易类型，在账户 dashboard 会出现内部转移交易
@property (nonatomic, assign) TransactionType type;
/// 如果没有 block time 使用 creation date
@property (nonatomic, strong, readonly, nonnull) NSDate *transactionTime;
/// int 确认数 = lastest block height - block height( > -1)，初始值来自 api，后会根据块高度变化更新
@property (nonatomic, assign, readonly) NSUInteger confirmations;


// TODO: delete
@property (nonatomic, copy, nullable) NSArray *queryAddresses;


- (nullable instancetype)initWithDictionary:(nullable NSDictionary *)dictionary;
+ (nullable NSArray *)batchInitWithArray:(nullable NSArray *)array;

@end


/// 输出项目
@interface OutItem : NSObject

///  Array<String> 输出地址
@property (nonatomic, strong, readonly, nonnull) NSArray<NSString *> *addresses;
/// long long 输出金额
@property (nonatomic, strong, readonly, nonnull) NSNumber *value;

- (nullable instancetype)initWithDictionary:(nullable NSDictionary *)dictionary;

@end

/// 输入项目
@interface InputItem : NSObject

///  Array<String> 输入地址
@property (nonatomic, strong, readonly, nonnull) NSArray<NSString *> *prevAddresses;
/// long long 前向交易输入金额
@property (nonatomic, strong, readonly, nonnull) NSNumber *prevValue;

- (nullable instancetype)initWithDictionary:(nullable NSDictionary *)dictionary;

@end
