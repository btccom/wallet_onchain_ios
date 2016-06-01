//
//  InversedSolidButton.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/5/31.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "InversedSolidButton.h"

@implementation InversedSolidButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor CBWWhiteColor] colorWithAlphaComponent:0.8];
        self.layer.cornerRadius = CBWCornerRadiusMini;
        self.layer.masksToBounds = YES;
        [self setTitleColor:[UIColor CBWPrimaryColor] forState:UIControlStateNormal];
        [self setTitleColor:[[UIColor CBWPrimaryColor] colorWithAlphaComponent:0.5f] forState:UIControlStateDisabled];
    }
    return self;
}

@end
