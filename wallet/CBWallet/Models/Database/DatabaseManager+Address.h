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

- (void)fetchAddressToStore:(AddressStore *)store;
- (void)saveAddress:(Address *)address;

@end
