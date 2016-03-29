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
@property (nonatomic, assign, getter=isArchived) BOOL archived;
/// 是否已经使用过
@property (nonatomic, assign, getter=isDirty) BOOL dirty;
@property (nonatomic, assign, getter=isInternal) BOOL internal;
@property (nonatomic, assign) long long balance;
@property (nonatomic, assign) NSUInteger txCount;

@property (nonatomic, assign) NSInteger accountRid;
@property (nonatomic, assign) NSInteger accountIdx;

/// create or import
+ (nonnull instancetype)newAdress:(nonnull NSString *)aAddress withLabel:(nullable NSString *)label idx:(NSInteger)idx archived:(BOOL)archived dirty:(BOOL)dirty internal:(BOOL)internal accountRid:(NSInteger)accountRid accountIdx:(NSInteger)accountIdx inStore:(nonnull AddressStore *)store;

/// create
+ (nonnull instancetype)newAdress:(nonnull NSString *)aAddress withLabel:(nullable NSString *)label idx:(NSInteger)idx accountRid:(NSInteger)accountRid accountIdx:(NSInteger)accountIdx inStore:(nonnull AddressStore *)store;

/// generate address with m/account idx/address idx
+ (nullable NSString *)addressStringWithIdx:(NSUInteger)idx acountIdx:(NSUInteger)accoundIdx;

/// 仅 watched address 支持删除方法
- (void)deleteWatchedAddressFromStore:(nonnull RecordObjectStore *)store;

@end
