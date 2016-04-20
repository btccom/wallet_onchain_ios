//
//  TransactionStore.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWTransactionStore.h"
#import "CBWAccount.h"

#import "NSDate+Helper.h"

@interface CBWTransactionStore ()

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSMutableDictionary *rows;

@end

@implementation CBWTransactionStore

- (void)setAccount:(CBWAccount *)account {
    if (![_account isEqual:account]) {
        _account = account;
        [self flush];
    }
}

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

- (instancetype)initWithAddressString:(NSString *)addressString {
    self = [super init];
    if (self) {
        _addressString = [addressString copy];
    }
    return self;
}

- (void)fetch {
    [super fetch];
    [self loadCache];
}

- (void)loadCache {
    NSString *path = [self p_cachedPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *cachedData = [NSData dataWithContentsOfFile:path];
        NSError *error = nil;
        NSArray *array = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"load transaction cache error: %@", error);
            return;
        }
        if (array.count > 0) {
            [self p_parseTransactionsWithArray:array];
        }
    }
}

- (void)flush {
    [self.sections removeAllObjects];
    [self.rows removeAllObjects];
    [super flush];
}

- (void)addTransactionsFromJsonObject:(id)jsonObject isCacheNeeded:(BOOL)isCacheNeeded {
    if (isCacheNeeded) {
//        [self flush];
        [self p_cacheJsonObject:jsonObject];
    }
    
    [self p_parseTransactionsWithArray:jsonObject];
    
    [self sort];
    
    [records enumerateObjectsUsingBlock:^(CBWRecordObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CBWTransaction *transaction = (CBWTransaction *)obj;
        NSString *day = [transaction.creationDate stringWithFormat:@"yyyy-MM-dd"];
        NSMutableArray *section = [self p_dequeueReusableSectionAtDay:day];
        if (![section containsObject:transaction]) {
            [section addObject:transaction];
            [section sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                CBWTransaction *t1 = obj1;
                CBWTransaction *t2 = obj2;
                return [t2.creationDate compare:t1.creationDate];// DESC
            }];
        }
    }];
}

- (void)sort {
    [records sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        CBWTransaction *t1 = obj1;
        CBWTransaction *t2 = obj2;
        return [t2.creationDate compare:t1.creationDate];// DESC
    }];
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

#pragma - Private Method

- (NSString *)p_cachedPath {
    NSString *fileName = self.addressString;
    if (!fileName) {
        fileName = [NSString stringWithFormat:@"account-%ld", self.account.idx];
    }
    NSString *cacheFileName = [NSString stringWithFormat:@"%@%@%@", CBWCacheTransactionPrefix, fileName, CBWCacheSubfix];
    return [CBWCachePath() stringByAppendingPathComponent:cacheFileName];
}

- (void)p_cacheJsonObject:(id)jsonObject {
    NSError *error = nil;
    NSData *cachedData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"json object to data error: %@", error);
        return;
    }
    
    if (![cachedData writeToFile:[self p_cachedPath] options:NSDataWritingAtomic error:&error]) {
        NSLog(@"cache transaction failed: %@", error);
    }
}

- (void)p_parseTransactionsWithArray:(id)array {
    if (![array isKindOfClass:[NSArray class]]) {
        return;
    }
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CBWTransaction *transaction = [[CBWTransaction alloc] initWithDictionary:obj];
        [self addRecord:transaction ASC:YES];
    }];
}

- (NSMutableArray *)p_dequeueReusableSectionAtDay:(NSString *)day {
    if (![self.sections containsObject:day]) {
        [self.sections addObject:day];
        [self.sections sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSDate *d1 = [NSDate dateFromString:obj1 withFormat:@"yyyy-MM-dd"];
            NSDate *d2 = [NSDate dateFromString:obj2 withFormat:@"yyyy-MM-dd"];
            return [d2 compare:d1];// DESC
        }];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [self.rows setObject:array forKey:day];
    }
    return [self.rows objectForKey:day];
}

@end
