//
//  SystemManager.h
//  wallet
//
//  Created by Zin on 16/2/24.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Master seed, RSA keypair, array of chain
@interface SystemManager : NSObject

// singleton factory method
+ (instancetype)defaultManager;

/// check wallet if valid
- (BOOL)checkWallet;

@end
