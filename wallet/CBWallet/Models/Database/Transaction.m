//
//  Transaction.m
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "Transaction.h"

@implementation Transaction

- (void)deleteFromStore:(RecordObjectStore *)store {
    DLog(@"will never delete a transaction");
    return;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"transaction, related address %@, %lld satoshi, %ld confirmed", self.relatedAddress, self.value, (unsigned long)self.confirmed];
}

@end
