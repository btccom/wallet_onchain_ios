//
//  UIColor+Wallet.m
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "UIColor+Wallet.h"

@implementation UIColor (Wallet)

+ (instancetype)walletPrimaryColor {
    return [self colorWithRed:22.f/255.f green:122.f/255.f blue:217.f/255.f alpha:1.f];
}
+ (instancetype)walletWhiteColor {
    return [self colorWithWhite:1.f alpha:1.f];
}
+ (instancetype)walletBlackColor {
    return [self colorWithWhite:58.f/255.f alpha:1.f];
};
+ (instancetype)walletGrayColor {
    return [self colorWithWhite:138.f/255.f alpha:1.f];
}
+ (instancetype)walletLightGrayColor {
    return [self colorWithWhite:239.f/255.f alpha:1.f];
}

/// white
+ (instancetype)walletBackgroundColor {
    return [self walletWhiteColor];
}
/// black
+ (instancetype)walletTextColor {
    return [self walletBlackColor];
}
/// gray
+ (instancetype)walletSubTextColor {
    return [self walletGrayColor];
}
/// light gray color, used for placeholder
+ (instancetype)walletMutedTextColor {
    return [self walletLightGrayColor];
}
/// extra light gray color
+ (instancetype)walletSeparatorColor {
    return [self colorWithWhite:245.f/255.f alpha:1.f];
}

/// green color
+ (instancetype)walletSuccessColor {
    return [self walletGreenColor];
}
+ (instancetype)walletGreenColor {
    return [self colorWithRed:17.f/255.f green:189.f/255.f blue:17.f/255.f alpha:1.f];
}

/// blue color
+ (instancetype)walletInfoColor {
    return [self walletBlueColor];
}
+ (instancetype)walletBlueColor {
    return [self blueColor];
}

/// yellow color
+ (instancetype)walletWarningColor {
    return [self walletYellowColor];
}
+ (instancetype)walletYellowColor {
    return [self yellowColor];
}

/// red color
+ (instancetype)walletDangerColor {
    return [self walletRedColor];
}
+ (instancetype)walletRedColor {
    return [self colorWithRed:210.f/255.f green:57.f/255.f blue:16.f/255.f alpha:1.f];
}

@end
