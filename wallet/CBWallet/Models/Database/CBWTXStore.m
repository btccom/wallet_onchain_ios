//
//  CBWTXStore.m
//  CBWallet
//
//  Created by Zin on 16/6/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWTXStore.h"

#import "NSDate+Helper.h"

@interface CBWTXStore ()

/// array of days
@property (nonatomic, strong) NSMutableArray<NSString *> *sections;
/// dictionary with day: transactions
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<CBWTransaction *> *> *rows;

@end

@implementation CBWTXStore

@synthesize page = _page, pageTotal = _pageTotal;


- (NSMutableArray *)sections {
    if (!_sections) {
        _sections = [[NSMutableArray alloc] init];
    }
    return _sections;
}

- (NSMutableDictionary *)rows {
    if (!_rows) {
        _rows = [[NSMutableDictionary alloc] init];
    }
    return _rows;
}

- (NSInteger)pageTotal {
    if (_pageTotal < 0) {
        NSUInteger count = [[CBWDatabaseManager defaultManager] transactionCountWithAddresses:self.queryAddresses];
        _pageTotal = ceil(count / (double)self.pagesize);
    }
    return _pageTotal;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _pagesize = CBWRecordObjectStorePagesizeDefault;
        _pageTotal = -1;
        _dateFormat = @"yyyy-MM-dd";
    }
    return self;
}

- (void)flush {
    [super flush];
    _page = 0;
    _pageTotal = -1;
    [self.sections removeAllObjects];
    [self.rows removeAllObjects];
}

- (void)fetch {
    [super fetch];
    
    [self fetchNextPage];
}

- (void)fetchNextPage {
    _page++;
    [self p_fetch];
}

- (NSUInteger)numberOfSections {
    return self.sections.count;
}

- (NSUInteger)numberOfRowsInSection:(NSUInteger)section {
    if (section < self.numberOfSections) {
        return [[self.rows objectForKey:[self.sections objectAtIndex:section]] count];
    }
    return 0;
}

- (NSString *)dayInSection:(NSUInteger)section {
    if (section < self.numberOfSections) {
        return [self.sections objectAtIndex:section];
    }
    return nil;
}

- (CBWTransaction *)transactionAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    NSString *day = [self dayInSection:section];
    if (day) {
        NSArray *sectionDatas = [self.rows objectForKey:day];
        NSUInteger row = indexPath.row;
        if (row < sectionDatas.count) {
            return [sectionDatas objectAtIndex:row];
        }
    }
    return nil;
}

#pragma mark - Private Method

- (void)p_fetch {
    
    __block NSArray *collection = nil;
    
    [[CBWDatabaseManager defaultManager] transactionFetchWithAddresses:self.queryAddresses page:self.page pagesize:self.pagesize completion:^(NSArray *response) {
        collection = response;
    }];
    
    DLog(@"database response: \n%@", collection);
    
    NSArray<CBWTransaction *> *txs = [CBWTransaction batchInitWithArray:collection];
    [txs enumerateObjectsUsingBlock:^(CBWTransaction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self p_addTransaction:obj];
    }];
}
/// 加入 store
- (BOOL)p_addTransaction:(CBWTransaction *)transaction {
    if ([self addRecord:transaction ASC:YES]) {
        [self p_detectTypeOfTransaction:transaction];
        transaction.queryAddresses = self.queryAddresses;
        [self p_didAddTransaction:transaction];
        return YES;
    }
    return NO;
}
/// 判断交易类型
- (void)p_detectTypeOfTransaction:(CBWTransaction *)transaction {
    if (self.queryAddresses.count == 1) {
        return;
    }
    __block long long accountInputsValue = 0;
    __block long long accountOutputsValue = 0;
    [transaction.inputs enumerateObjectsUsingBlock:^(InputItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        [item.prevAddresses enumerateObjectsUsingBlock:^(NSString * _Nonnull address, NSUInteger idx, BOOL * _Nonnull addressStop) {
            if ([self.queryAddresses containsObject:address]) {// 此处不严谨，仅对当前 api 及钱包有效
                accountInputsValue += [item.prevValue longLongValue];
                *addressStop = YES;// 找到一个即可，避免重复添加
            }
        }];
    }];
    [transaction.outputs enumerateObjectsUsingBlock:^(OutItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        [item.addresses enumerateObjectsUsingBlock:^(NSString * _Nonnull address, NSUInteger idx, BOOL * _Nonnull addressStop) {
            if ([self.queryAddresses containsObject:address]) {
                accountOutputsValue += [item.value longLongValue];
                *addressStop = YES;
            }
        }];
    }];
    if (accountOutputsValue == transaction.outputsValue && accountInputsValue == transaction.inputsValue) {
        [transaction setValue:@(accountOutputsValue) forKey:@"value"];
        transaction.type = TransactionTypeInternal;
    } else {
        [transaction setValue:@(accountOutputsValue - accountInputsValue) forKey:@"value"];
        if (accountOutputsValue > accountInputsValue) {
            transaction.type = TransactionTypeReceive;
        } else {
            transaction.type = TransactionTypeSend;
        }
    }
}
/// 整理数据，按日期分组
- (void)p_didAddTransaction:(CBWTransaction *)transaction {
    NSString *day = [transaction.transactionTime stringWithFormat:self.dateFormat];
    NSMutableArray<CBWTransaction *> *rows = [self p_dequeueReusableRowsAtDay:day];
    if (![rows containsObject:transaction]) {
        [rows addObject:transaction];
        [rows sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            CBWTransaction *t1 = obj1;
            CBWTransaction *t2 = obj2;
            return [t2.transactionTime compare:t1.transactionTime];// DESC
        }];
    }
}
/// 找出排序过的日期对应的数据
- (NSMutableArray *)p_dequeueReusableRowsAtDay:(NSString *)day {
    if (![self.sections containsObject:day]) {
        // 新建
        [self.sections addObject:day];
        // 排序
        [self.sections sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSDate *d1 = [NSDate dateFromString:obj1 withFormat:self.dateFormat];
            NSDate *d2 = [NSDate dateFromString:obj2 withFormat:self.dateFormat];
            return [d2 compare:d1];// DESC
        }];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [self.rows setObject:array forKey:day];
    }
    return [self.rows objectForKey:day];
}

@end
