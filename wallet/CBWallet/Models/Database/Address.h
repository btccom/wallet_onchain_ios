//
//  Address.h
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "RecordObject.h"

@class AddressStore;

@interface Address : RecordObject

/// idx < 0 means watched address
@property (nonatomic, assign) NSInteger idx;
@property (nonatomic, copy) NSString * _Nonnull address;
@property (nonatomic, copy) NSString * _Nullable label;
/// 是否已经使用过
@property (nonatomic, assign, getter=isDirty) BOOL dirty;
@property (nonatomic, assign) long long balance;
@property (nonatomic, assign) NSUInteger txCount;

@property (nonatomic, assign) NSInteger accountRid;
@property (nonatomic, assign) NSInteger accountIdx;

/// create or import
+ (nonnull instancetype)newAdress:(nonnull NSString *)aAddress withLabel:(nullable NSString *)label idx:(NSInteger)idx dirty:(BOOL)dirty accountRid:(NSInteger)accountRid accountIdx:(NSInteger)accountIdx inStore:(nonnull AddressStore *)store;

@end
