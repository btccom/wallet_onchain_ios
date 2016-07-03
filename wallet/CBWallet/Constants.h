//
//  Constants.h
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/21.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#ifndef Constants_h
#define Constants_h


static const NSInteger CBWRecordWatchedIDX = -1;
static const NSInteger CBWMaxVisibleConfirmation = 100;

// User Defaults

/// number, use long long value
static NSString *const CBWUserDefaultsCustomFee = @"cbw.user.defaults.fee.custom";

/// bool value
static NSString *const CBWUserDefaultsTestnetEnabled = @"cbw.user.defaults.testnet.enabled";

/// bool value
static NSString *const CBWUserDefaultsiCloudEnabledKey = @"cbw.user.defaults.icloud.enabled";
/// bool value
//static NSString *const CBWUserDefaultsTouchIdEnabledKey = @"cbw.user.defaults.touchid.enabled";

/// intenger value
static NSString *const CBWUserDefaultsLocalVersion = @"cbw.user.defaults.localVersion";

/// date value
static NSString *const  CBWUserDefaultsiCloudSyncDateKey = @"cbw.user.defaults.icloud.sync.date";

// Keychain
// services
static NSString *const CBWKeychainSeedService = @"com.btc.wallet.seed";
static NSString *const CBWKeychainHintService = @"com.btc.wallet.hint";
/// master password field
static NSString *const CBWKeychainMasterPasswordService = @"com.btc.wallet.masterPassword";
/// if enabled touch id, ON or others
static NSString *const CBWKeychainTouchIDService = @"com.btc.wallet.touchID";

/// keychain touch id on value
static NSString *const CBWKeychainTouchIDON = @"ON";

// keychain account
static NSString *const CBWKeychainAccountDefault = @"com.btc.wallet";

// Notification
static NSString *const CBWNotificationCheckedIn = @"cbw.notification.checked.in";
static NSString *const CBWNotificationCheckedOut = @"cbw.notification.checked.out";
static NSString *const CBWNotificationSignedOut = @"cbw.notification.signed.out";
static NSString *const CBWNotificationWalletCreated = @"cbw.notification.wallet.created";
static NSString *const CBWNotificationWalletRecovered = @"cbw.notification.wallet.recovered";

static NSString *const CBWNotificationTransactionCreated = @"cbw.notification.transaction.created";

// common error
static NSString *const CBWErrorDomain = @"cbw.error";
static const NSInteger CBWErrorCodeUserCanceledTransaction = 70001;
static const NSInteger CBWErrorCodeInvalidBackupImageNoSeedData = 77001;
static const NSInteger CBWErrorCodeInvalidBackupImageInvalidSeedData = 77002;

// Cache
static NSString *const CBWCacheSubfix = @".cache";
static NSString *const CBWCacheTransactionPrefix = @"cbw-transaction-";

#endif /* Constants_h */
