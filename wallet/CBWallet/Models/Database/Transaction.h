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

@property (nonatomic, copy) NSString * _Nonnull hashId;
/// 对方地址
@property (nonatomic, copy) NSString * _Nonnull relatedAddress;
/// 交易数量，正负值，单位 satoshi
@property (nonatomic, assign) long long value;
@property (nonatomic, assign) TransactionType type;
@property (nonatomic, assign) NSUInteger confirmed;

@end
