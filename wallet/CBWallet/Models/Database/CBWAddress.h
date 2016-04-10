//
//  Address.h
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRecordObject.h"

@class CBWAddressStore;

@interface CBWAddress : CBWRecordObject

/// idx < 0 means watched address
@property (nonatomic, assign) NSInteger idx;
@property (nonatomic, copy) NSString * _Nonnull address;
@property (nonatomic, copy) NSString * _Nullable label;
@property (nonatomic, assign, getter=isArchived) BOOL archived;
/// 是否已经使用过
@property (nonatomic, assign, getter=isDirty) BOOL dirty;
@property (nonatomic, assign, getter=isInternal) BOOL internal;
/// long long int
@property (nonatomic, assign) long long balance;
/// unsigned integer
@property (nonatomic, assign) NSUInteger txCount;

@property (nonatomic, assign) long long accountRid;
@property (nonatomic, assign) NSInteger accountIdx;

/// create or import
+ (nonnull instancetype)newAdress:(nonnull NSString *)aAddress withLabel:(nullable NSString *)label idx:(NSInteger)idx archived:(BOOL)archived dirty:(BOOL)dirty internal:(BOOL)internal accountRid:(long long)accountRid accountIdx:(NSInteger)accountIdx inStore:(nonnull CBWAddressStore *)store;

/// create
+ (nonnull instancetype)newAdress:(nonnull NSString *)aAddress withLabel:(nullable NSString *)label idx:(NSInteger)idx accountRid:(long long)accountRid accountIdx:(NSInteger)accountIdx inStore:(nonnull CBWAddressStore *)store;

/// generate address with m/account idx/address idx
+ (nullable NSString *)addressStringWithIdx:(NSUInteger)idx acountIdx:(NSUInteger)accoundIdx;

+ (BOOL)checkAddressString:(nullable NSString *)addressString;

/// 仅 watched address 支持删除方法
- (void)deleteWatchedAddressFromStore:(nonnull CBWRecordObjectStore *)store;

- (void)updateWithDictionary:(nullable id)dictionary;

@end
