//
//  PrimaryButton.m
//  CBWallet
//
//  Created by Zin on 16/3/15.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "PrimaryButton.h"

@implementation PrimaryButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor CBWPrimaryColor];
        [self setTitleColor:[UIColor CBWWhiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[[UIColor CBWWhiteColor] colorWithAlphaComponent:0.5f] forState:UIControlStateDisabled];
    }
    return self;
}

@end
