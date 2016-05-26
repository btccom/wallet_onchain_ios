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

- (long long)totalBalance {
    __block long long balance = 0;
    [records enumerateObjectsUsingBlock:^(CBWRecordObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CBWAddress *address = (CBWAddress *)obj;
        balance += address.balance;
    }];
    return balance;
}

- (void)fetch {
    [super fetch];
    [[CBWDatabaseManager defaultManager] fetchAddressesWithAccountIdx:self.accountIdx archived:self.isArchived toStore:self];
    [self p_sort];
}

- (void)fetchAllAddresses {
    [super fetch];
    [[CBWDatabaseManager defaultManager] fetchAddressesWithAccountIdx:self.accountIdx toStore:self];
    [self p_sort];
}

- (void)p_sort {
    [records sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        CBWAddress *address1 = obj1;
        CBWAddress *address2 = obj2;
        if (address1.label.length > 0 && address2.label.length == 0) {
            return NSOrderedAscending;
        } else if (address2.label.length > 0 && address1.label.length == 0) {
            return NSOrderedDescending;
        } else if (address1.label.length > 0 && address2.label.length > 0) {
            return [address1.label compare:address2.label];
        } else {
            return [address1.address compare:address2.address];
        }
        
    }];
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
    DLog(@"update addresses: %@", addresses);
    if ([addresses isKindOfClass:[NSArray class]]) {
        [addresses enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dictionary = obj;
                CBWAddress *address = [self addressWithAddressString:[dictionary objectForKey:@"address"]];
                if (address) {
                    [address updateWithDictionary:dictionary];
                    [address saveWithError:nil];
                }
                
            }
        }];
    } else if ([addresses isKindOfClass:[NSDictionary class]]) {
        // 只有一条记录
        CBWAddress *address = [self addressWithAddressString:[addresses objectForKey:@"address"]];
        if (address) {
            [address updateWithDictionary:addresses];
            [address saveWithError:nil];
        }
    }
}

- (NSArray *)availableAddresses {
    return [records copy];
}

@end
