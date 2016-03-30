//
//  CBWRequest+Address.h
//  CBWallet
//
//  Created by Zin on 16/3/28.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRequest.h"

@interface CBWRequest (Address)

- (void)addressSummaryWithAddressString:(nonnull NSString *)addressString completion:(nullable CBWRequestCompletion)completion;
- (void)addressTransactionsWithAddressString:(nonnull NSString *)addressString page:(NSUInteger)page pagesize:(NSUInteger)pagesize completion:(nullable CBWRequestCompletion)completion;
- (void)addressUnspentWithAddressString:(nonnull NSString *)addressString completion:(nullable CBWRequestCompletion)completion;
@end
