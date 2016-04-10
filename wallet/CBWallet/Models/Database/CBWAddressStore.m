//
//  AddressStore.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWAddressStore.h"
#import "CBWDatabaseManager.h"

@implementation CBWAddressStore

- (instancetype)initWithAccountIdx:(NSInteger)accountIdx {
    self = [super init];
    if (self) {
        _accountIdx = accountIdx;
    }
    return self;
}

- (void)fetch {
    [super fetch];
    if (self.isArchived) {
        [[CBWDatabaseManager defaultManager] fetchAddressWithAccountIdx:self.accountIdx archived:YES toStore:self];
        return;
    }
    [[CBWDatabaseManager defaultManager] fetchAddressWithAccountIdx:self.accountIdx toStore:self];
}

- (NSUInteger)countAllAddresses {
    return [[CBWDatabaseManager defaultManager] countAllAddressesWithAccountIdx:self.accountIdx];
}

- (NSArray *)allAddressStrings {
    __block NSMutableArray *strings = [NSMutableArray arrayWithCapacity:records.count];
    [records enumerateObjectsUsingBlock:^(CBWRecordObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [strings addObject:((CBWAddress *)obj).address];
    }];
    
    return [strings copy];
}

- (CBWAddress *)addressWithAddressString:(NSString *)addressString {
    if (!addressString) {
        return nil;
    }
    __block CBWAddress *address = nil;
    [records enumerateObjectsUsingBlock:^(CBWRecordObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CBWAddress *theAddress = (CBWAddress *)obj;
        if ([theAddress.address isEqualToString:addressString]) {
            address = theAddress;
            *stop = YES;
        }
    }];
    return address;
}

- (void)updateAddresses:(id)addresses {
    if ([addresses isKindOfClass:[NSArray class]]) {
        [addresses enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isKindOfClass:[NSNull class]]) {
                
                NSDictionary *dictionary = obj;
                CBWAddress *address = [self addressWithAddressString:[dictionary objectForKey:@"address"]];
                if (address) {
                    [address updateWithDictionary:dictionary];
                    [address saveWithError:nil];
                }
                
            }
        }];
    }
}

@end
