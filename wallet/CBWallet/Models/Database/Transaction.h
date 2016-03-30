//
//  Transaction.h
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "RecordObject.h"

typedef NS_ENUM(NSUInteger, TransactionType) {
    TransactionTypeSend = 0,
    TransactionTypeReceive
};

@interface Transaction : RecordObject

@property (nonatomic, copy, readonly, nonnull) NSString *hashId;
@property (nonatomic, assign) NSInteger blockHeight;
@property (nonatomic, assign, readonly) TransactionType type;
/// 交易数量，正负值，单位 satoshi
@property (nonatomic, assign, readonly) long long value;

// 需计算的属性
/// 相关地址
@property (nonatomic, copy, readonly, nonnull) NSArray *relatedAddresses;

// relation
/// array of InputItem
@property (nonatomic, strong, readonly, nonnull) NSArray *inputs;
/// array of OutItem
@property (nonatomic, strong, readonly, nonnull) NSArray *outputs;

- (nullable instancetype)initWithDictionary:(nullable NSDictionary *)dictionary;

- (NSUInteger)confirmedCount;

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
