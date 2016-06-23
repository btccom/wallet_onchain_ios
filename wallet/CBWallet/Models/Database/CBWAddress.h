//
//  Address.h
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRecordObject.h"


/// 可通过查询数据库判断，但不一定准确，例如恢复帐户时，可能有遗漏地址
typedef NS_ENUM(NSUInteger, AddressScope) {
    /// 未知
    AddressScopeUnknown,
    /// 外部地址
    AddressScopeExternal,
    /// 私有账户地址
    AddressScopePrivate,
    /// 观察地址
    AddressScopeWatched
};


@class CBWAddressStore, BTCKey;

@interface CBWAddress : CBWRecordObject

/// idx < 0 means watched address
@property (nonatomic, assign) NSInteger idx;
@property (nonatomic, copy, nonnull) NSString *address;
@property (nonatomic, copy, nullable) NSString *label;
@property (nonatomic, assign, getter=isArchived) BOOL archived;
/// 是否已经使用过
@property (nonatomic, assign, getter=isDirty) BOOL dirty;
@property (nonatomic, assign, getter=isInternal) BOOL internal;
/// long long int
@property (nonatomic, assign) long long balance;
/// unsigned integer
@property (nonatomic, assign) NSUInteger txCount;
@property (nonatomic, assign) NSUInteger unconfirmedTXCount;
@property (nonatomic, assign) long long received;
@property (nonatomic, assign) long long sent;

@property (nonatomic, assign) long long accountRID;
@property (nonatomic, assign) NSInteger accountIDX;

/// only for account idx > 0
@property (nonatomic, strong, readonly, nullable) BTCKey *privateKey;

@property (nonatomic, strong, readonly, nullable) NSString *testAddress;

@property (nonatomic, assign, readonly) AddressScope scope;

/// create or import
+ (nonnull instancetype)newAdress:(nonnull NSString *)aAddress withLabel:(nullable NSString *)label idx:(NSInteger)idx archived:(BOOL)archived dirty:(BOOL)dirty internal:(BOOL)internal accountRid:(long long)accountRid accountIdx:(NSInteger)accountIdx inStore:(nonnull CBWAddressStore *)store;

/// create
+ (nonnull instancetype)newAdress:(nonnull NSString *)aAddress withLabel:(nullable NSString *)label idx:(NSInteger)idx accountRid:(long long)accountRid accountIdx:(NSInteger)accountIdx inStore:(nonnull CBWAddressStore *)store;

/// generate address with m/account idx/address idx
+ (nullable NSString *)addressStringWithIdx:(NSUInteger)idx acountIdx:(NSUInteger)accoundIdx;

+ (BOOL)validateAddressString:(nullable NSString *)addressString;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dictionary;

/// 仅 watched address 支持删除方法
- (void)deleteWatchedAddressFromStore:(nonnull CBWRecordObjectStore *)store;

- (void)updateWithDictionary:(nullable id)dictionary;

@end
