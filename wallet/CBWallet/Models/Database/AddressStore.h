//
//  AddressStore.h
//  CBWallet
//
//  Created by Zin on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "RecordObjectStore.h"
#import "Address.h"

@interface AddressStore : RecordObjectStore

@property (nonatomic, assign) NSInteger accountIdx;
@property (nonatomic, assign, getter=isArchived) BOOL archived;

- (instancetype)initWithAccountIdx:(NSInteger)accountIdx;

- (NSUInteger)countAllAddresses;

@end
