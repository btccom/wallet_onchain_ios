//
//  Transaction.m
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "Transaction.h"
#import "TransactionStore.h"

@implementation Transaction
@synthesize relatedAddresses = _relatedAddresses;

- (NSArray *)relatedAddresses {
    if (!_relatedAddresses) {
        //TODO: 优化判断
        NSString *selfAddress = ((TransactionStore *)self.store).addressString;
        __block NSMutableArray *addresses = [NSMutableArray array];
        if (self.type == TransactionTypeSend) {
            [self.outData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                OutItem *o = obj;
                if (![o.addr containsObject:selfAddress]) {
                    [o.addr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        // 去重
                        if (![addresses containsObject:obj]) {
                            [addresses addObject:obj];
                        }
                    }];
                }
            }];
        } else {
            [self.inputsData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                InputItem *i = obj;
                if (![i.prevOut.addr containsObject:selfAddress]) {
                    [i.prevOut.addr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        // 去重
                        if (![addresses containsObject:obj]) {
                            [addresses addObject:obj];
                        }
                    }];
                }
            }];
        }
        _relatedAddresses = [addresses copy];
    }
    return _relatedAddresses;
}

#pragma mark - Initialization
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (instancetype)init {
    return nil;
}

+ (instancetype)newRecordInStore:(RecordObjectStore *)store {
    return nil;
}

#pragma mark - Public Method

- (void)deleteFromStore:(RecordObjectStore *)store {
    DLog(@"will never delete a transaction");
    return;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"transaction, related addresses %@, %lld satoshi, %ld confirmed", self.relatedAddresses, self.value, (unsigned long)self.confirmed];
}

#pragma mark - KVC
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"hash"]) {
        _hashId = value;
    } else if ([key isEqualToString:@"balance_diff"]) {
        _value = [value longLongValue];
        _type = (_value > 0) ? TransactionTypeReceive : TransactionTypeSend;
    } else if ([key isEqualToString:@"inputs"]) {
        // handle inputs data
        if ([value isKindOfClass:[NSArray class]]) {
            __block NSMutableArray *inputs = [NSMutableArray array];// capacity = vin_size
            [value enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                InputItem *i = [[InputItem alloc] initWithDictionary:obj];
                if (i) {
                    [inputs addObject:i];
                }
            }];
            _inputsData = [inputs copy];
        }
    } else if ([key isEqualToString:@"out"]) {
        // handle out
        if ([value isKindOfClass:[NSArray class]]) {
            __block NSMutableArray *outs = [NSMutableArray array];
            [value enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                OutItem *o = [[OutItem alloc] initWithDictionary:obj];
                if (o) {
                    [outs addObject:o];
                }
            }];
            _outData = [outs copy];
        }
    } else if ([key isEqualToString:@"time"]) {
        NSTimeInterval timestamp = [value doubleValue];
        self.creationDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    }
}

@end

@implementation OutItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (instancetype)init {
    return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    // ignore
}
- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

@end

@implementation InputItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"prev_out"]) {
        _prevOut = [[OutItem alloc] initWithDictionary:value];
    }
}

@end
