//
//  CBWTXStore.h
//  CBWallet
//
//  Created by Zin on 16/6/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRecordObjectStore.h"
#import "CBWTransaction.h"

@class CBWTXStore;

@protocol CBWTXStoreDelegate <NSObject>

@optional
- (void)txStoreDidCompleteFetch:(nonnull CBWTXStore *)store;

@end

@interface CBWTXStore : CBWRecordObjectStore

///
@property (nonatomic, copy, nullable) NSArray *queryAddresses;
@property (nonatomic, assign) NSInteger accountIDX;

@property (nonatomic, assign, readonly) NSUInteger page;
@property (nonatomic, assign, readonly) NSInteger pageTotal;
@property (nonatomic, assign) NSUInteger pagesize;

@property (nonatomic, copy, nullable) NSString *dateFormat;

@property (nonatomic, weak, nullable) id<CBWTXStoreDelegate> delegate;

- (void)fetchNextPage;

/// 按日排序后
- (NSUInteger)numberOfSections;
- (NSUInteger)numberOfRowsInSection:(NSUInteger)section;
- (nullable NSString *)dayInSection:(NSUInteger)section;
- (nullable CBWTransaction *)transactionAtIndexPath:(nonnull NSIndexPath *)indexPath;


@end
