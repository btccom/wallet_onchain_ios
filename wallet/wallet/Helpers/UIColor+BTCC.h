//
//  UIColor+BTCC.h
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (BTCC)

+ (instancetype)BTCCPrimaryColor;
+ (instancetype)BTCCWhiteColor;
+ (instancetype)BTCCBlackColor;
+ (instancetype)BTCCGrayColor;
+ (instancetype)BTCCLightGrayColor;
+ (instancetype)BTCCExtraLightGrayColor;

/// white
+ (instancetype)BTCCBackgroundColor;
/// black
+ (instancetype)BTCCTextColor;
/// gray
+ (instancetype)BTCCSubTextColor;
/// light gray color, used for placeholder
+ (instancetype)BTCCMutedTextColor;
/// extra light gray color
+ (instancetype)BTCCSeparatorColor;

/// green color
+ (instancetype)BTCCSuccessColor;
+ (instancetype)BTCCGreenColor;

/// blue color
+ (instancetype)BTCCInfoColor;
+ (instancetype)BTCCBlueColor;

/// yellow color
+ (instancetype)BTCCWarningColor;
+ (instancetype)BTCCYellowColor;

/// red color
+ (instancetype)BTCCDangerColor;
+ (instancetype)BTCCRedColor;

@end
