//
//  UIColor+Wallet.h
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Wallet)

+ (instancetype)walletPrimaryColor;
+ (instancetype)walletWhiteColor;
+ (instancetype)walletBlackColor;
+ (instancetype)walletGrayColor;
+ (instancetype)walletLightGrayColor;
+ (instancetype)walletExtraLightGrayColor;

/// white
+ (instancetype)walletBackgroundColor;
/// black
+ (instancetype)walletTextColor;
/// gray
+ (instancetype)walletSubTextColor;
/// light gray color, used for placeholder
+ (instancetype)walletMutedTextColor;
/// extra light gray color
+ (instancetype)walletSeparatorColor;

/// green color
+ (instancetype)walletSuccessColor;
+ (instancetype)walletGreenColor;

/// blue color
+ (instancetype)walletInfoColor;
+ (instancetype)walletBlueColor;

/// yellow color
+ (instancetype)walletWarningColor;
+ (instancetype)walletYellowColor;

/// red color
+ (instancetype)walletDangerColor;
+ (instancetype)walletRedColor;

@end
