//
//  CBWTransactionSync.h
//  CBWallet
//
//  Created by Zin on 16/6/23.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const CBWTransactionSyncInsertedCountKey;
extern NSString *const CBWTransactionSyncConfirmedCountKey;

typedef void(^syncProgressBlock) (NSString *message);
/// sync completion
///@param error NSError
///@param updatedAddresses <code>{address:{inserted:n, confirmed:n},...}</code>
typedef void(^syncCompletionBlock) (NSError *error, NSDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *updatedAddresses);

@interface CBWTransactionSync : NSObject

//@property (nonatomic, assign) NSInteger accountIDX;

- (void)syncWithAddresses:(NSArray<NSString *> *)addresses progress:(syncProgressBlock)progress completion:(syncCompletionBlock)completion;

@end
