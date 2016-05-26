//
//  DatabaseManager+Address.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWDatabaseManager.h"

@class CBWAddress, CBWAddressStore;

@interface CBWDatabaseManager (Address)

/// 读取全部地址
- (void)fetchAddressesWithAccountIdx:(NSInteger)accountIdx toStore:(CBWAddressStore *)store;
/// 读取地址，指定是否存档
- (void)fetchAddressesWithAccountIdx:(NSInteger)accountIdx archived:(BOOL)archived toStore:(CBWAddressStore *)store;
- (void)saveAddress:(CBWAddress *)address;
- (void)deleteAddress:(CBWAddress *)address;
- (NSUInteger)countAllAddressesWithAccountIdx:(NSInteger)accountIdx;

@end
