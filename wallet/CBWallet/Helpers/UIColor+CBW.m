//
//  UIColor+CBW.m
//  wallet
//
//  Created by Zin on 16/2/25.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "UIColor+CBW.h"

@implementation UIColor (CBW)

+ (instancetype)CBWPrimaryColor {
    return [self colorWithRed:22.f/255.f green:122.f/255.f blue:217.f/255.f alpha:1.f];
}
+ (instancetype)CBWPrimaryDarkColor {
    return [self colorWithRed:17.f/255.f green:97.f/255.f blue:173.f/255.f alpha:1.f];
}
+ (instancetype)CBWWhiteColor {
    return [self colorWithWhite:1.f alpha:1.f];
}
+ (instancetype)CBWBlackColor {
    return [self colorWithWhite:58.f/255.f alpha:1.f];
};
+ (instancetype)CBWGrayColor {
    return [self colorWithWhite:138.f/255.f alpha:1.f];
}
+ (instancetype)CBWLightGrayColor {
    return [self colorWithWhite:220.f/255.f alpha:1.f];
}
+ (instancetype)CBWExtraLightGrayColor {
    return [self colorWithWhite:241.f/255.f alpha:1.f];
}

+ (instancetype)CBWDrawerBackgroundColor {
    return [self colorWithRed:16.f/255.f green:91.f/255.f blue:162.f/255.f alpha:1.f];
}

/// white
+ (instancetype)CBWBackgroundColor {
    return [self CBWWhiteColor];
}
/// black
+ (instancetype)CBWTextColor {
    return [self CBWBlackColor];
}
/// gray
+ (instancetype)CBWSubTextColor {
    return [self CBWGrayColor];
}
/// light gray color, used for placeholder
+ (instancetype)CBWMutedTextColor {
    return [self CBWLightGrayColor];
}
/// extra light gray color
+ (instancetype)CBWSeparatorColor {
    return [self CBWExtraLightGrayColor];
}

/// green color
+ (instancetype)CBWSuccessColor {
    return [self CBWGreenColor];
}
+ (instancetype)CBWGreenColor {
    return [self colorWithRed:17.f/255.f green:189.f/255.f blue:17.f/255.f alpha:1.f];
}

/// blue color
+ (instancetype)CBWInfoColor {
    return [self CBWBlueColor];
}
+ (instancetype)CBWBlueColor {
    return [self blueColor];
}

/// yellow color
+ (instancetype)CBWWarningColor {
    return [self CBWYellowColor];
}
+ (instancetype)CBWYellowColor {
    return [self yellowColor];
}

/// red color
+ (instancetype)CBWDangerColor {
    return [self CBWRedColor];
}
+ (instancetype)CBWRedColor {
    return [self colorWithRed:210.f/255.f green:57.f/255.f blue:16.f/255.f alpha:1.f];
}

@end
