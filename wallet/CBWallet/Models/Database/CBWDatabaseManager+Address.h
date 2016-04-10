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

- (void)fetchAddressWithAccountIdx:(NSInteger)accountIdx toStore:(CBWAddressStore *)store;
- (void)fetchAddressWithAccountIdx:(NSInteger)accountIdx archived:(BOOL)archived toStore:(CBWAddressStore *)store;
- (void)saveAddress:(CBWAddress *)address;
- (void)deleteAddress:(CBWAddress *)address;
- (NSUInteger)countAllAddressesWithAccountIdx:(NSInteger)accountIdx;

@end
