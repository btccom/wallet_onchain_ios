//
//  Address.m
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "Address.h"
#import "AddressStore.h"

@implementation Address

+ (instancetype)newAdress:(NSString *)aAddress withLabel:(NSString *)label idx:(NSInteger)idx dirty:(BOOL)dirty accountRid:(NSInteger)accountRid accountIdx:(NSInteger)accountIdx inStore:(AddressStore *)store {
    Address *address = [Address newRecordInStore:store];
    address.address = aAddress;
    address.label = label;
    address.idx = idx;
    address.dirty = dirty;
    address.accountRid = accountRid;
    address.accountIdx = accountIdx;
    return address;
}

//- (void)deleteFromStore:(RecordObjectStore *)store {
//    DLog(@"will never delete an address");
//    return;
//}

- (NSString *)description {
    return [NSString stringWithFormat:@"address %@: %@, %lld satoshi", self.label, self.address, self.balance];
}

@end
