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
    TransactionTypeReceive
};

@interface CBWTransaction : CBWRecordObject
/// string 交易哈希
@property (nonatomic, copy, readonly, nonnull) NSString *hashID;
/// int 所在块高度
@property (nonatomic, assign, readonly) NSInteger blockHeight;
/// 交易数量，正负值，单位 satoshi
@property (nonatomic, assign, readonly) long long value;

@property (nonatomic, strong, readonly, nonnull) NSDate *transactionTime;

// 详情
/// 所在块时间
@property (nonatomic, strong, readonly, nullable) NSDate *blockTime;
/// long long 该交易的手续费
@property (nonatomic, assign) long long fee;
/// int 输入数量
@property (nonatomic, assign, readonly) NSUInteger inputsCount;
/// long long 输入金额
@property (nonatomic, assign, readonly) long long inputsValue;
/// int 输出数量
@property (nonatomic, assign, readonly) NSUInteger outputsCount;
/// long long 输出金额
@property (nonatomic, assign, readonly) long long outputsValue;
/// boolean 是否为 coinbase 交易
@property (nonatomic, assign, readonly) BOOL isCoinbase;
/// int 交易体积
@property (nonatomic, assign, readonly) NSUInteger size;
/// int 交易版本号
@property (nonatomic, assign, readonly) NSUInteger version;
/// int 确认数
@property (nonatomic, assign, readonly) NSUInteger confirmations;


// 需计算的属性
@property (nonatomic, assign, readonly) TransactionType type;
/// 相关地址
@property (nonatomic, copy, readonly, nonnull) NSArray *relatedAddresses;
/// 查询地址，交易查询路径通常为 地址 -> 交易 -> 详情
@property (nonatomic, copy, nullable) NSString *queryAddress;

// relation
/// array of InputItem
@property (nonatomic, strong, readonly, nonnull) NSArray *inputs;
/// array of OutItem
@property (nonatomic, strong, readonly, nonnull) NSArray *outputs;

- (nullable instancetype)initWithDictionary:(nullable NSDictionary *)dictionary;

//- (NSUInteger)confirmedCount;

@end

@interface OutItem : NSObject

///  Array<String> 输出地址
@property (nonatomic, strong, readonly, nonnull) NSArray *addresses;
/// long long 输出金额
@property (nonatomic, strong, readonly, nonnull) NSNumber *value;

- (nullable instancetype)initWithDictionary:(nullable NSDictionary *)dictionary;

@end

@interface InputItem : NSObject

///  Array<String> 输入地址
@property (nonatomic, strong, readonly, nonnull) NSArray *prevAddresses;
/// long long 前向交易输入金额
@property (nonatomic, strong, readonly, nonnull) NSNumber *prevValue;

- (nullable instancetype)initWithDictionary:(nullable NSDictionary *)dictionary;

@end
