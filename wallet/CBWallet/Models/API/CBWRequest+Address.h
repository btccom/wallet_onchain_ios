//
//  CBWRequest+Address.h
//  CBWallet
//
//  Created by Zin on 16/3/28.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRequest.h"

@interface CBWRequest (Address)

- (void)addressTransactionsWithAddressString:(nonnull NSString *)addressString limit:(NSUInteger)limit timestamp:(NSUInteger)timestamp completion:(nullable CBWRequestCompletion)completion;

@end
