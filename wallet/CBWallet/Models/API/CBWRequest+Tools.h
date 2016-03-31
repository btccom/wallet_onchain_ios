//
//  CBWRequest+Tools.h
//  CBWallet
//
//  Created by Zin on 16/3/31.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRequest.h"

@interface CBWRequest (Tools)

- (void)toolsPublishTxHex:(nonnull NSString *)hex withCompletion:(nullable CBWRequestCompletion)completion;

@end
