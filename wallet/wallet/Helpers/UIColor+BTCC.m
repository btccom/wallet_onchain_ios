//
//  UIColor+BTCC.m
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "UIColor+BTCC.h"

@implementation UIColor (BTCC)

+ (instancetype)BTCCPrimaryColor {
    return [self colorWithRed:22.f/255.f green:122.f/255.f blue:217.f/255.f alpha:1.f];
}
+ (instancetype)BTCCWhiteColor {
    return [self colorWithWhite:1.f alpha:1.f];
}
+ (instancetype)BTCCBlackColor {
    return [self colorWithWhite:58.f/255.f alpha:1.f];
};
+ (instancetype)BTCCGrayColor {
    return [self colorWithWhite:138.f/255.f alpha:1.f];
}
+ (instancetype)BTCCLightGrayColor {
    return [self colorWithWhite:220.f/255.f alpha:1.f];
}
+ (instancetype)BTCCExtraLightGrayColor {
    return [self colorWithWhite:241.f/255.f alpha:1.f];
}

/// white
+ (instancetype)BTCCBackgroundColor {
    return [self BTCCWhiteColor];
}
/// black
+ (instancetype)BTCCTextColor {
    return [self BTCCBlackColor];
}
/// gray
+ (instancetype)BTCCSubTextColor {
    return [self BTCCGrayColor];
}
/// light gray color, used for placeholder
+ (instancetype)BTCCMutedTextColor {
    return [self BTCCLightGrayColor];
}
/// extra light gray color
+ (instancetype)BTCCSeparatorColor {
    return [self BTCCExtraLightGrayColor];
}

/// green color
+ (instancetype)BTCCSuccessColor {
    return [self BTCCGreenColor];
}
+ (instancetype)BTCCGreenColor {
    return [self colorWithRed:17.f/255.f green:189.f/255.f blue:17.f/255.f alpha:1.f];
}

/// blue color
+ (instancetype)BTCCInfoColor {
    return [self BTCCBlueColor];
}
+ (instancetype)BTCCBlueColor {
    return [self blueColor];
}

/// yellow color
+ (instancetype)BTCCWarningColor {
    return [self BTCCYellowColor];
}
+ (instancetype)BTCCYellowColor {
    return [self yellowColor];
}

/// red color
+ (instancetype)BTCCDangerColor {
    return [self BTCCRedColor];
}
+ (instancetype)BTCCRedColor {
    return [self colorWithRed:210.f/255.f green:57.f/255.f blue:16.f/255.f alpha:1.f];
}

@end
