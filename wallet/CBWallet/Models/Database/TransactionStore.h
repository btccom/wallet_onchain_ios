//
//  TransactionStore.h
//  CBWallet
//
//  Created by Zin on 16/3/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "RecordObjectStore.h"
#import "Transaction.h"

/// 使用 plist 文件缓存，暂时不存入数据库
@interface TransactionStore : RecordObjectStore

@end
