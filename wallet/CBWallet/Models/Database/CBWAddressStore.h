//
//  AddressStore.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRecordObjectStore.h"
#import "CBWAddress.h"

@interface CBWAddressStore : CBWRecordObjectStore

@property (nonatomic, assign) NSInteger accountIdx;
@property (nonatomic, assign, getter=isArchived) BOOL archived;

- (nonnull instancetype)initWithAccountIdx:(NSInteger)accountIdx;

/// 查询余额，默认非存档地址
- (long long)totalBalance;

/// 包含已存档地址
- (void)fetchAllAddresses;

/// 包含已存档地址
- (NSUInteger)countAllAddresses;

- (nonnull NSArray *)allAddressStrings;

- (nullable CBWAddress *)addressWithAddressString:(nullable NSString *)addressString;

/// 批量更新地址到数据库
- (void)updateAddresses:(nullable id)addresses;

- (nullable NSArray *)availableAddresses;

@end
