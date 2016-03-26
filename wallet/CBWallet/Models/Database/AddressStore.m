//
//  AddressStore.m
//  CBWallet
//
//  Created by Zin on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "AddressStore.h"
#import "DatabaseManager.h"

@implementation AddressStore

- (void)fetch {
    [records removeAllObjects];
    [[DatabaseManager defaultManager] fetchAddressToStore:self];
}

@end
