//
//  Constants.h
//  CBWallet
//
//  Created by Zin on 16/3/21.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#ifndef Constants_h
#define Constants_h


static const NSInteger CBWRecordWatchedIdx = -1;
static const NSInteger CBWMaxConfirmedCount = 100;

// User Defaults

/// bool value
static NSString *const CBWUserDefaultsiCloudEnabledKey = @"cbw.user.defaults.icloud.enabled";
/// bool value
static NSString *const CBWUserDefaultsTouchIdEnabledKey = @"cbw.user.defaults.touchid.enabled";

/// intenger value
static NSString *const CBWUserDefaultsLocalVersion = @"cbw.user.defaults.localVersion";

// Key Chain
static NSString *const CBWKeyChainSeedService = @"com.btc.wallet.seed";
//static NSString *const CBWKeyChainMasterPasswordService = @"com.btc.wallet.masterPassword";
static NSString *const CBWKeyChainAccountDefault = @"com.btc.wallet";

// Notification
static NSString *const CBWNotificationCheckedIn = @"cbw.notification.checked.in";
static NSString *const CBWNotificationCheckedOut = @"cbw.notification.checked.out";
static NSString *const CBWNotificationWalletCreated = @"cbw.notification.wallet.created";
static NSString *const CBWNotificationWalletRecovered = @"cbw.notification.wallet.recovered";


#endif /* Constants_h */
