//
//  SendViewController+Send.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/4/29.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "SendViewController.h"

@interface SendViewController (Send)
/// 发款，快速发款，使用默认找零地址
///@param addresses <code><b>NSDictionary</b> {address: long long int}</code>
- (void)sendToAddresses:(NSDictionary *)toAddresses withCompletion:(void (^)(NSError *error))completion;
/// 发款，可以在高级发款中指定找零地址
///@param addresses <code><b>NSDictionary</b> {address: long long int}</code>
///@param address <code>nil</code> 时使用 fromAddresses 余额最多（本地数据，未查询 unspent）的第一个地址
- (void)sendToAddresses:(NSDictionary *)toAddresses withChangeAddress:(CBWAddress *)address fee:(long long)fee completion:(void (^)(NSError *error))completion;
@end
