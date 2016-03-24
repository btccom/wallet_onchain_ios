//
//  Constants.h
//  CBWallet
//
//  Created by Zin on 16/3/21.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#ifndef Constants_h
#define Constants_h


// User Defaults

/// bool value
static NSString *const CBWUserDefaultsiCloudEnabledKey = @"cbw.user.defaults.icloud.enabled";
/// bool value
static NSString *const CBWUserDefaultsTouchIdEnabledKey = @"cbw.user.defaults.touchid.enabled";


// Key Chain
static NSString *const CBWKeyChainSeedService = @"com.btc.wallet.seed";
static NSString *const CBWKeyChainMasterPasswordService = @"com.btc.wallet.masterPassword";
static NSString *const CBWKeyChainAccountDefault = @"com.btc.wallet";


#endif /* Constants_h */
