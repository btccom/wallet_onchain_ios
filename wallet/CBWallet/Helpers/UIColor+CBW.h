//
//  UIColor+CBW.h
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (CBW)

+ (instancetype)CBWPrimaryColor;
+ (instancetype)CBWPrimaryDarkColor;
+ (instancetype)CBWWhiteColor;
+ (instancetype)CBWBlackColor;
+ (instancetype)CBWGrayColor;
+ (instancetype)CBWLightGrayColor;
+ (instancetype)CBWExtraLightGrayColor;

+ (instancetype)CBWDrawerBackgroundColor;
/// white
+ (instancetype)CBWBackgroundColor;
/// black
+ (instancetype)CBWTextColor;
/// gray
+ (instancetype)CBWSubTextColor;
/// light gray color, used for placeholder
+ (instancetype)CBWMutedTextColor;
/// extra light gray color
+ (instancetype)CBWSeparatorColor;

/// green color
+ (instancetype)CBWSuccessColor;
+ (instancetype)CBWGreenColor;

/// blue color
+ (instancetype)CBWInfoColor;
+ (instancetype)CBWBlueColor;

/// yellow color
+ (instancetype)CBWWarningColor;
+ (instancetype)CBWYellowColor;

/// red color
+ (instancetype)CBWDangerColor;
+ (instancetype)CBWRedColor;

@end
