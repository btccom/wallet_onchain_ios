//
//  Address.m
//  wallet
//
//  Created by Zin (noteon.com) on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWAddress.h"
#import "CBWAddressStore.h"
#import "Guard.h"

#import "SSKeychain.h"
#import <CoreBitcoin/CoreBitcoin.h>
#import "AESCrypt.h"

@implementation CBWAddress
@synthesize privateKey = _privateKey, testAddress = _testAddress;

- (BTCKey *)privateKey {
    if (self.accountIDX < 0) {
        // not work for watched account
        return nil;
    }
    
    if ([Guard globalGuard].code.length > 0) {
        // checked in
        if (!_privateKey) {
            NSString *encryptedSeed = [SSKeychain passwordForService:CBWKeychainSeedService account:CBWKeychainAccountDefault];
            NSString *seed = [AESCrypt decrypt:encryptedSeed password:[Guard globalGuard].code];
            
            if (seed) {
                NSData *btcSeedData = BTCDataWithUTF8CString(seed.UTF8String);
                BTCKeychain *masterChain = [[BTCKeychain alloc] initWithSeed:btcSeedData];
                NSString *path = [NSString stringWithFormat:@"%lu/0/%lu", (unsigned long)self.accountIDX, (unsigned long)self.idx];
                _privateKey = [masterChain derivedKeychainWithPath:path].key;
            }
        }
        
        return _privateKey;
    }
    
    return nil;
}

- (NSString *)testAddress {
    if (self.accountIDX < 0) {
        return nil;
    }
    
    if (!_testAddress) {
        NSString *encryptedSeed = [SSKeychain passwordForService:CBWKeychainSeedService account:CBWKeychainAccountDefault];
        NSString *seed = [AESCrypt decrypt:encryptedSeed password:[Guard globalGuard].code];
        
        if (seed) {
            NSData *btcSeedData = BTCDataWithUTF8CString(seed.UTF8String);
            BTCKeychain *masterChain = [[BTCKeychain alloc] initWithSeed:btcSeedData];
            NSString *path = [NSString stringWithFormat:@"%lu/0/%lu", (unsigned long)self.accountIDX, (unsigned long)self.idx];
            _testAddress = [masterChain derivedKeychainWithPath:path].key.addressTestnet.string;
        }
    }
    
    return _testAddress;
}

+ (instancetype)newAdress:(NSString *)aAddress withLabel:(NSString *)label idx:(NSInteger)idx archived:(BOOL)archived dirty:(BOOL)dirty internal:(BOOL)internal accountRid:(long long)accountRid accountIdx:(NSInteger)accountIdx inStore:(nonnull CBWAddressStore *)store {
    CBWAddress *address = [CBWAddress new];
    address.address = aAddress;
    address.label = label;
    address.idx = idx;
    address.archived = archived;
    address.dirty = dirty;
    address.internal = internal;
    address.accountRID = accountRid;
    address.accountIDX = accountIdx;
    address.balance = 0;
    if ([store containsRecord:address]) {
        DLog(@"duplicated address: %@", aAddress);
        return nil;
    } else {
        [store addRecord:address];
    }
    
    DLog(@"new address: %@", address);
    return address;
}

+ (instancetype)newAdress:(NSString *)aAddress withLabel:(NSString *)label idx:(NSInteger)idx accountRid:(long long)accountRid accountIdx:(NSInteger)accountIdx inStore:(CBWAddressStore *)store {
    return [self newAdress:aAddress withLabel:label idx:idx archived:NO dirty:NO internal:NO accountRid:accountRid accountIdx:accountIdx inStore:store];
}

+ (NSString *)addressStringWithIdx:(NSUInteger)idx acountIdx:(NSUInteger)accoundIdx {
    if ([Guard globalGuard].code.length > 0) {
        
        DLog(@"address, try to get seed");
        
        NSString *encryptedSeed = [SSKeychain passwordForService:CBWKeychainSeedService account:CBWKeychainAccountDefault];
        NSString *seed = [AESCrypt decrypt:encryptedSeed password:[Guard globalGuard].code];
        
        if (seed) {
            NSData *btcSeedData = BTCDataWithUTF8CString(seed.UTF8String);
            BTCKeychain *masterChain = [[BTCKeychain alloc] initWithSeed:btcSeedData];
            NSString *path = [NSString stringWithFormat:@"%lu/0/%lu", (unsigned long)accoundIdx, (unsigned long)idx];
            NSString *address = [masterChain derivedKeychainWithPath:path].key.compressedPublicKeyAddress.string;
            DLog(@"generated address string: %@, path: %@", address, path);
            return address;
        }
    }
    
    return nil;
}

+ (BOOL)validateAddressString:(NSString *)addressString {
    if (![addressString isKindOfClass:[NSString class]]) {
        return NO;
    }
    BTCAddress *address = [BTCAddress addressWithString:addressString];
    if (address) {
        return YES;
    }
    return NO;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

+ (NSArray<CBWAddress *> *)batchInitWithArray:(NSArray<NSDictionary *> *)array {
    if (array) {
        __block NSMutableArray *addresses = [NSMutableArray arrayWithCapacity:array.count];
        [array enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                CBWAddress *address = [[CBWAddress alloc] initWithDictionary:obj];
                [addresses addObject:address];
            }
        }];
        return [addresses copy];
    }
    return nil;
}

- (BOOL)saveWithError:(NSError *__autoreleasing  _Nullable *)error {
    BOOL initial = self.rid < 0;
    if (initial) {
        [self.store willChangeValueForKey:CBWRecordObjectStoreCountKey];
    }
    if (self.isArchived != ((CBWAddressStore *)self.store).isArchived) {
        [self.store deleteRecord:self];
    }
    [[CBWDatabaseManager defaultManager] saveAddress:self];
    if (initial) {
        [self.store didChangeValueForKey:CBWRecordObjectStoreCountKey];
    }
    return NO;
}

//- (void)deleteFromStore {
//    DLog(@"will never delete an address");
//    return;
//}

- (void)deleteWatchedAddressFromStore:(CBWRecordObjectStore *)store {
    if (self.accountIDX != CBWRecordWatchedIDX) {
        return;
    }
    
    [[CBWDatabaseManager defaultManager] deleteAddress:self];
    [store deleteRecord:self];
}

/*
 {
 address = 1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa;
 balance = 6618011597;
 "first_tx" = 4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b;
 "last_tx" = 29069fa3e5a70a9cc6a792c031a7b8fe0d4a5eab42d530cb3199c4a08b794dc4;
 received = 6618011597;
 sent = 0;
 "tx_count" = 1034;
 "unconfirmed_received" = 0;
 "unconfirmed_sent" = 0;
 "unconfirmed_tx_count" = 0;
 "unspent_tx_count" = 1034;
 }
 */
 - (void)updateWithDictionary:(id)dictionary {
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }
    [self setValuesForKeysWithDictionary:dictionary];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[CBWAddress class]]) {
        return NO;
    }
    if ([self.address isEqual:((CBWAddress *)object).address]) {
        return YES;
    }
    return NO;
}

#pragma mark - KVC
- (void)setValue:(id)value forKey:(NSString *)key {
    if ([value isKindOfClass:[NSNull class]]) {
        return;
    }
    
    if ([key isEqualToString:@"balance"]) {
        self.balance = [value isKindOfClass:[NSNull class]] ? 0 : [value longLongValue];
    } else {
        [super setValue:value forKey:key];
    }
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([value isKindOfClass:[NSNull class]]) {
        return;
    }
    
    if ([key isEqualToString:@"tx_count"]) {
        self.txCount = [value unsignedIntegerValue];
    } else if ([key isEqualToString:@"unconfirmed_tx_count"]) {
        self.unconfirmedTXCount = [value unsignedIntegerValue];
    } else if ([key isEqualToString:@"first_tx"]) {
        _firstTXHashID = value;
    } else if ([key isEqualToString:@"last_tx"]) {
        _lastTXHashID = value;
    }
}


- (NSString *)description {
    return [NSString stringWithFormat:@"address [%ld] %@ - %@, %lld satoshi", (long)self.idx, self.label, self.address, self.balance];
}

@end
