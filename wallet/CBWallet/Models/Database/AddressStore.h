//
//  AddressStore.h
//  CBWallet
//
//  Created by Zin on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "RecordObjectStore.h"
#import "Address.h"

@interface AddressStore : RecordObjectStore

@property (nonatomic, assign) NSInteger accountIdx;
@property (nonatomic, assign, getter=isArchived) BOOL archived;

- (nonnull instancetype)initWithAccountIdx:(NSInteger)accountIdx;

- (NSUInteger)countAllAddresses;

- (nonnull NSArray *)allAddressStrings;

- (nullable Address *)addressWithAddressString:(nullable NSString *)addressString;

/// 批量更新地址到数据库
- (void)updateAddresses:(nullable id)addresses;

@end
