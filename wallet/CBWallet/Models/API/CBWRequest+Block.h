//
//  CBWRequest+Block.h
//  CBWallet
//
//  Created by Zin on 16/3/30.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRequest.h"

@interface CBWRequest (Block)
- (void)blockLatestWithCompletion:(nullable CBWRequestCompletion)completion;
@end
