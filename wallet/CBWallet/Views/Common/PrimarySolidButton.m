//
//  PrimarySolidButton.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "PrimarySolidButton.h"

@implementation PrimarySolidButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor CBWPrimaryColor];
        self.layer.cornerRadius = CBWCornerRadiusMini;
        self.layer.masksToBounds = YES;
        [self setTitleColor:[UIColor CBWWhiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[[UIColor CBWWhiteColor] colorWithAlphaComponent:0.5f] forState:UIControlStateDisabled];
    }
    return self;
}

@end
