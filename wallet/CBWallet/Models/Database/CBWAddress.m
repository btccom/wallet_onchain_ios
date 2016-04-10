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

+ (instancetype)newAdress:(NSString *)aAddress withLabel:(NSString *)label idx:(NSInteger)idx archived:(BOOL)archived dirty:(BOOL)dirty internal:(BOOL)internal accountRid:(long long)accountRid accountIdx:(NSInteger)accountIdx inStore:(nonnull CBWAddressStore *)store {
    CBWAddress *address = [CBWAddress newRecordInStore:store];
    address.address = aAddress;
    address.label = label;
    address.idx = idx;
    address.archived = archived;
    address.dirty = dirty;
    address.internal = internal;
    address.accountRid = accountRid;
    address.accountIdx = accountIdx;
    address.balance = 0;
    DLog(@"new address: %@", address);
    return address;
}

+ (instancetype)newAdress:(NSString *)aAddress withLabel:(NSString *)label idx:(NSInteger)idx accountRid:(long long)accountRid accountIdx:(NSInteger)accountIdx inStore:(CBWAddressStore *)store {
    return [self newAdress:aAddress withLabel:label idx:idx archived:NO dirty:NO internal:NO accountRid:accountRid accountIdx:accountIdx inStore:store];
}

+ (NSString *)addressStringWithIdx:(NSUInteger)idx acountIdx:(NSUInteger)accoundIdx {
    if ([Guard globalGuard].code.length > 0) {
        
        DLog(@"address, try to get seed");
        
        NSString *encryptedSeed = [SSKeychain passwordForService:CBWKeyChainSeedService account:CBWKeyChainAccountDefault];
        NSString *seed = [AESCrypt decrypt:encryptedSeed password:[Guard globalGuard].code];
        
        if (seed) {
            NSData *btcSeedData = BTCDataWithUTF8CString(seed.UTF8String);
            BTCKeychain *masterChain = [[BTCKeychain alloc] initWithSeed:btcSeedData];
            NSString *path = [NSString stringWithFormat:@"%lu/0/%lu", (unsigned long)accoundIdx, (unsigned long)idx];
            NSString *address = [masterChain derivedKeychainWithPath:path].key.compressedPublicKeyAddress.string;
            DLog(@"generated address string: %@", address);
            return address;
        }
    }
    
    return nil;
}

+ (BOOL)checkAddressString:(NSString *)addressString {
    if (![addressString isKindOfClass:[NSString class]]) {
        return NO;
    }
    BTCAddress *address = [BTCAddress addressWithString:addressString];
    if (address) {
        return YES;
    }
    return NO;
}

- (void)saveWithError:(NSError *__autoreleasing  _Nullable *)error {
    if (self.isArchived != ((CBWAddressStore *)self.store).isArchived) {
        [self.store deleteRecord:self];
    }
    [[CBWDatabaseManager defaultManager] saveAddress:self];
}

//- (void)deleteFromStore:(RecordObjectStore *)store {
//    DLog(@"will never delete an address");
//    return;
//}

- (void)deleteWatchedAddressFromStore:(CBWRecordObjectStore *)store {
    if (self.accountIdx != CBWRecordWatchedIdx) {
        return;
    }
    
    [store deleteRecord:self];
    [[CBWDatabaseManager defaultManager] deleteAddress:self];
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
    if ([key isEqualToString:@"balance"]) {
        self.balance = [value isKindOfClass:[NSNull class]] ? 0 : [value longLongValue];
    } else {
        [super setValue:value forKey:key];
    }
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"tx_count"]) {
        self.txCount = [value isKindOfClass:[NSNull class]] ? 0 : [value unsignedIntegerValue];
    }
}


- (NSString *)description {
    return [NSString stringWithFormat:@"address %@: %@, %lld satoshi", self.label, self.address, self.balance];
}

@end
