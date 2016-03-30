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

@property (nonatomic, copy, nonnull) NSString *hashId;
/// 交易数量，正负值，单位 satoshi
@property (nonatomic, assign) long long value;
@property (nonatomic, assign) TransactionType type;
/// 相关地址
@property (nonatomic, copy, readonly, nonnull) NSArray *relatedAddresses;
@property (nonatomic, assign) NSInteger blockHeight;

/// array of InputItem
@property (nonatomic, strong, readonly, nonnull) NSArray *inputsData;
/// array of OutItem
@property (nonatomic, strong, readonly, nonnull) NSArray *outData;

- (nullable instancetype)initWithDictionary:(nullable NSDictionary *)dictionary;

- (NSUInteger)confirmedCount;

@end

@interface OutItem : NSObject

@property (nonatomic, strong, readonly, nonnull) NSArray *addr;// of address string
@property (nonatomic, strong, readonly, nonnull) NSNumber *value;// long long value

- (nullable instancetype)initWithDictionary:(nullable NSDictionary *)dictionary;

@end

@interface InputItem : NSObject

@property (nonatomic, strong, readonly, nonnull) OutItem *prevOut;

- (nullable instancetype)initWithDictionary:(nullable NSDictionary *)dictionary;

@end
