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
        [[DatabaseManager defaultManager] fetchAddressWithAccountIdx:self.accountIdx archived:YES toStore:self];
        return;
    }
    [[DatabaseManager defaultManager] fetchAddressWithAccountIdx:self.accountIdx toStore:self];
}

- (NSUInteger)countAllAddresses {
    return [[DatabaseManager defaultManager] countAllAddressesWithAccountIdx:self.accountIdx];
}

- (NSArray *)allAddressStrings {
    __block NSMutableArray *strings = [NSMutableArray arrayWithCapacity:records.count];
    [records enumerateObjectsUsingBlock:^(RecordObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [strings addObject:((Address *)obj).address];
    }];
    
    return [strings copy];
}

- (Address *)addressWithAddressString:(NSString *)addressString {
    if (!addressString) {
        return nil;
    }
    __block Address *address = nil;
    [records enumerateObjectsUsingBlock:^(RecordObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Address *theAddress = (Address *)obj;
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
                Address *address = [self addressWithAddressString:[dictionary objectForKey:@"address"]];
                if (address) {
                    [address updateWithDictionary:dictionary];
                    [address saveWithError:nil];
                }
                
            }
        }];
    }
}

@end
