//
//  SendViewController+Send.h
//  CBWallet
//
//  Created by Zin on 16/4/29.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "SendViewController.h"

@interface SendViewController (Send)
/// 发款
///@param addresses <code><b>NSDictionary</b> {address: long long int}</code>
- (void)sendToAddresses:(NSDictionary *)toAddresses;
@end
