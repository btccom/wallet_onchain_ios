//
//  DatabaseManager+Address.h
//  CBWallet
//
//  Created by Zin on 16/3/26.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "DatabaseManager.h"

@class Address, AddressStore;

@interface DatabaseManager (Address)

- (void)fetchAddressWithAccountIdx:(NSInteger)accountIdx toStore:(AddressStore *)store;
- (void)fetchAddressWithAccountIdx:(NSInteger)accountIdx archived:(BOOL)archived toStore:(AddressStore *)store;
- (void)saveAddress:(Address *)address;
- (NSUInteger)countAllAddressesWithAccountIdx:(NSInteger)accountIdx;

@end
